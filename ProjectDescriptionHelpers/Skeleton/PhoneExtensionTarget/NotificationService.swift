import ProjectDescription

public extension Skeleton.PhoneAppModule {
    struct NotificationService: PhoneExtensionTarget {
        enum CodingKeys: String, CodingKey {
            case extensionName
            case bundleIdentifier
            case name
        }

        public var extensionName: String
        public var name: String
        public var dependencies: ModuleDependencies
        public var entitlements: ProjectDescription.Entitlements?
        public var customScripts: [Skeleton.CustomScript] = []
        public var platforms: PlatformFilters { [.ios] }
        public var bundleIdentifier: String
        public var environment: Skeleton.PhoneAppModule<AppConstants>.Environment
        public var deploymentTargets: DeploymentTargets { .iOS(environment.iOSDeploymentTarget) }
        public init(environment: Skeleton.PhoneAppModule<AppConstants>.Environment,
                    appName: String,
                    extensionName: String = "NotificationService",
                    extensionIdentifier: String = "NotificationService",
                    dependencies: ModuleDependencies,
                    entitlements: ProjectDescription.Entitlements? = nil,
                    customScripts: [Skeleton.CustomScript] = []) {
            self.environment = environment
            name = "\(appName)\(extensionName)\(environment.name)"
            self.extensionName = extensionName
            self.dependencies = dependencies
            self.entitlements = entitlements
            self.customScripts = customScripts
            bundleIdentifier = environment.bundleIdentifier + "." + extensionIdentifier
        }

        public func makeTarget(_ app: Skeleton.PhoneAppModule<AppConstants>) -> Target {
            .target(name: name,
                    destinations: app.destinations,
                    product: .appExtension,
                    bundleId: bundleIdentifier,
                    deploymentTargets: .iOS(environment.iOSDeploymentTarget),
                    infoPlist: .extendingDefault(with: ["CFBundleDisplayName": "\(extensionName)",
                                                        "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                                                        "NSExtension": [
                                                            "NSExtensionPointIdentifier": "com.apple.usernotifications.service",
                                                            "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService"
                                                        ]]),
                    sources: .sources(in: "Extensions/NotificationService/Sources"),
                    resources: .resources(in: "Extensions/NotificationService/Sources"),
                    dependencies: Array(dependencies.make()),
                    settings: .settings(base: environment.settings.settingValue,
                                        configurations: environment.configurations))
        }

        public func dependency(appName: String) -> TargetDependency? {
            .target(name: "\(appName)\(extensionName)\(environment.name)",
                    condition: .when(deploymentTargets.filters))
        }
    }
}
