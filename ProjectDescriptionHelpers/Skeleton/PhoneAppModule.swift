import ProjectDescription

public extension Skeleton {
    struct PhoneAppModule<AppConstants: Encodable & Equatable & Sendable>: AppModule {
        enum CodingKeys: CodingKey {
            case name
            case folder
            case environments
            case organizationName
            case entitlements
            case extensions
        }

        public var path: ProjectDescription.Path { "Sources/Apps/\(folder)" }

        public var name: String
        public var folder: String
        public var platform: Platform { .iOS }
        public var destinations: Destinations = [.iPhone, .iPad]
        public var platforms: PlatformFilters {
            Set([.ios])
        }

        public func testInfo() -> Skeleton.TestInfo {
            testInfo(for: .iOS)
        }

        public func testInfo(for platform: Platform) -> Skeleton.TestInfo {
            switch platform {
            case .iOS: .init(isTestable: isTestable, targetName: "\(name)Devel")
            default: .none
            }
        }

        public var extensions: [String: [PhoneExtension]] = [:]
        public var environments: [Environment]
        public var deploymentTargets: DeploymentTargets
        public var dependencies: ModuleDependencies
        public var organizationName: String
        public var supplementarySources: [String] = []
        public var supplementaryResources: [String] = []
        public var entitlements: ProjectDescription.Entitlements?
        public var customScripts: [Skeleton.CustomScript] = []
        public var isTestable: Bool
        public var appVersion: String
        public var supportsParallelTesting: Bool
        public init(name: String,
                    folder: String,
                    destinations: Destinations,
                    iOSVersion: String,
                    appVersion: String,
                    environments: [Environment],
                    organizationName: String,
                    dependencies: ModuleDependencies,
                    supplementarySources: [String] = [],
                    supplementaryResources: [String] = [],
                    entitlements: ProjectDescription.Entitlements? = nil,
                    customScripts: [Skeleton.CustomScript] = [],
                    isTestable: Bool = true,
                    supportsParallelTesting: Bool = true,
                    extensions: (Environment) -> [PhoneExtension] = { _ in [] }) {
            self.name = name
            self.appVersion = appVersion
            self.organizationName = organizationName
            deploymentTargets = .iOS(iOSVersion)
            self.folder = folder
            self.destinations = destinations.filter { $0.platform == .iOS }
            self.isTestable = isTestable
            self.supportsParallelTesting = supportsParallelTesting
            self.environments = environments
            self.organizationName = organizationName
            self.dependencies = dependencies
            self.supplementarySources = supplementarySources
            self.supplementaryResources = supplementaryResources
            self.customScripts = customScripts
            self.entitlements = entitlements

            self.extensions = environments.reduce(into: [String: [PhoneExtension]]()) { dictionary, environment in
                dictionary[environment.name] = extensions(environment)
            }
        }

        public func targets() -> [Target] {
            let targets = environments
                .flatMap { environment in
                    [phoneTarget(environment: environment)]
                        + (extensions[environment.name]?.map { $0.target(self) } ?? [])
                }

            let testTargets = environments
                .filter { $0.isTestable }
                .map { environment in
                    phoneTestTarget(environment)
                }
            return targets + testTargets
        }

        public func project() -> Project {
            let schemes: [Scheme] = environments
                .map { environment in
                    let text = "\(name)\(environment.name)"
                    let hasTests = environment.isTestable
                    let testInfo = testInfo(for: platform)
                    return Scheme.scheme(name: text,
                                         buildAction: .buildAction(targets: ["\(text)"],
                                                                   preActions: []),
                                         testAction: hasTests ? .targets(["\(testInfo.testTargetName)"],
                                                                         options: .options(coverage: true)) : nil,
                                         runAction: .runAction(),
                                         archiveAction: .archiveAction(configuration: .release),
                                         analyzeAction: .analyzeAction(configuration: .debug))
                }

            return Project(
                name: name,
                organizationName: organizationName,
                options: .options(),
                settings: .settings(base: ["MARKETING_VERSION":
                        "\(appVersion)"]),
                targets: targets(),
                schemes: schemes,
                resourceSynthesizers: [.environment, .plists(), .fonts(), .assets()]
            )
        }
    }
}

private extension Skeleton.PhoneAppModule {
    func phoneTarget(environment: Environment) -> Target {
        .target(name: "\(name)\(environment.name)",
                destinations: destinations,
                product: .app,
                productName: environment.productName,
                bundleId: environment.bundleIdentifier,
                deploymentTargets: .iOS(environment.iOSDeploymentTarget),
                infoPlist: .extendingDefault(with: environment.plist.plistValue),
                sources: .sources(in: (["Sources" as String, "../Shared/Sources"] + supplementarySources).map { folderPrefix + $0 }),
                resources: .resources(in: (["Sources" as String, "../Shared/Sources", environment.customResourcesFolder] + supplementaryResources).map { folderPrefix + $0 }),
                entitlements: .dictionary(environment.entitlements.reduce(into: [:]) {
                    $0[$1.key] = $1.value.plistValue
                }),
                scripts: [.sourcery(),
                          .swiftlint(),
                          .post(script: "rm -rf \"${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Environment.environment\"",
                                name: "Remove environment files from IPA",
                                basedOnDependencyAnalysis: false)] + customScripts.compactMap { $0.targetScript(for: self, environment: environment) },
                dependencies: appTargetDependencies(from: environment),
                settings: .settings(base: environment.settings.settingValue,
                                    configurations: environment.configurations))
    }

    private func phoneTestTarget(_ environment: Environment) -> Target {
        .target(name: testInfo(for: platform).testTargetName,
                destinations: .iOS,
                product: .unitTests,
                bundleId: "\(environment.bundleIdentifier).tests",
                deploymentTargets: nil,
                sources: .sources(in: ["Tests" as String, "../Shared/Tests"].map { folderPrefix + $0 }),
                resources: .resources(in: ["Tests" as String, "../Shared/Tests"].map { folderPrefix + $0 }),
                dependencies: dependencies.make() + [.target(name: "\(name)\(environment.name)")])
    }

    private func appTargetDependencies(from environment: Environment) -> [TargetDependency] {
        dependencies.make()
            + (extensions[environment.name]?.compactMap { $0.dependency(self) } ?? [])
    }
}

public extension Skeleton.PhoneAppModule {
    struct Environment: AppEnvironment {
        /// Used to generate local app environment. This object should contain every app/API key, baseurl and global string.

        public let name: String
        public let productName: String
        public let folder: String
        public let bundleIdentifier: String
        public let constants: AppConstants
        public let teamID: String
        public let entitlements: [String: DictionaryValue]
        public let plist: [String: DictionaryValue]
        public let fastlane: Fastlane
        public var settings: [String: DictionaryValue]
        public var customResourcesFolder: String
        public var isTestable: Bool
        public var iOSDeploymentTarget: String

        public init(name: String,
                    productName: String,
                    folder: String = "App",
                    fastlane: Fastlane,
                    bundleIdentifier: String,
                    constants: AppConstants,
                    iOSDeploymentTarget: String,
                    teamID: String,
                    displayName: String?,
                    entitlements: [String: DictionaryValue],
                    plist: [String: DictionaryValue],
                    customSettings: [String: DictionaryValue] = [:],
                    isTestable: Bool) {
            self.name = name
            self.productName = productName
            self.folder = folder
            self.bundleIdentifier = bundleIdentifier
            self.constants = constants
            self.iOSDeploymentTarget = iOSDeploymentTarget
            self.entitlements = entitlements
            self.plist = plist.merging(["CFBundleDisplayName": "\(displayName ?? name)",
                                        "UIApplicationSceneManifest":
                                            ["UISceneConfigurations": [
                                                "UIWindowSceneSessionRoleApplication": [[
                                                    "UISceneClassName": "UIWindowScene",
                                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                                ]]
                                            ]],
                                        "CFBundleShortVersionString": "$(MARKETING_VERSION)"],
                                       uniquingKeysWith: { _, new in new })
            self.fastlane = fastlane
            self.teamID = teamID
            customResourcesFolder = "Resources/\(name)"
            settings = customSettings.reduce(into: ["OTHER_LDFLAGS": "-ObjC",
                                                    "INTENTS_CODEGEN_LANGUAGE": "Swift",
                                                    "MARKETING_VERSION": "\(ProjectDescription.Environment.versionName.getString(default: "1.0.0"))",
                                                    "DEVELOPMENT_TEAM": .string(teamID)]) {
                $0[$1.key] = $1.value
            }
            self.isTestable = isTestable
        }

        var configurations: [Configuration] {
            [.debug(name: "Debug",
                    settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) \(name.uppercased())"]),
             .release(name: "Release",
                      settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) \(name.uppercased())"])]
        }
    }
}
