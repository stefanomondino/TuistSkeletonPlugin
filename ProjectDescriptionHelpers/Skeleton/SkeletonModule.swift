import ProjectDescription

public extension Skeleton {
    struct TestDependencies: ModuleDependencies {
        public var isPrivate: Bool { true }
        public var test: [TestModule]
        public var external: [ExternalModule]
        public var dependencies: [DependencyBuilder] { test }
        public init(test: [TestModule] = [], external: [ExternalModule] = []) {
            self.test = test
            self.external = external
        }
    }
}

public enum SwiftVersion: Sendable, CustomStringConvertible {
    case v5
    case v6
    public static var `default`: Self { .v5 }
    public var description: String {
        switch self {
        case .v5: "5"
        case .v6: "6"
        }
    }
}

public protocol SkeletonModule: ProjectConvertible, DependencyBuilder {
    var name: String { get }
    var deploymentTargets: ProjectDescription.DeploymentTargets { get }
    var hasDemoApp: Bool { get }
    var path: ProjectDescription.Path { get }
    var destinations: Destinations { get }
    var dependencies: ModuleDependencies { get }
    var testDependencies: ModuleDependencies { get }
    var settings: Settings? { get }
    var synthesizers: [ResourceSynthesizer] { get }
    var product: Product { get }
    var useSourcery: Bool { get }
    var bundleId: String { get }
    var customScripts: [TargetScript] { get }
    var swiftVersion: SwiftVersion { get }
    func mainTarget(destinations: Destinations) -> Target
    func testTarget(destinations: Destinations) -> Target
    func demoAppTarget(platform: Platform, destinations: Destinations) -> Target?
}

public extension SkeletonModule {
    
    var customScripts: [TargetScript] { [] }
    
    var bundleId: String {
        "app.framework.\(name)"
    }

    func testAppName(for platform: Platform) -> String {
        "\(name)TestApp_\(platform)"
    }

    func mainTarget(destinations: Destinations) -> Target {
        .target(name: name,
                destinations: destinations,
                product: product,
                productName: name,
                bundleId: bundleId,
                deploymentTargets: deploymentTargets,
                infoPlist: .extendingDefault(with: [:]),
                sources: .sources(in: folderPrefix + "Sources"),
                resources: .resources(in: folderPrefix + "Sources"),
                scripts: [.sourcery()].filter { _ in useSourcery } + customScripts,
                dependencies: makeDependencies() + macroDependency(),
                settings: settings,
                mergedBinaryType: .disabled, mergeable: false)
    }
    
    private var macroName: String {
        name + "Macro"
    }
    // This static condition is for futureproofing macros.
    #if TUIST_NATIVE_MACRO
    private var tuistMacro: Bool { true }
    private var macroPath: String {
        name + "Macro"
    }
    private func macroDependency() -> [TargetDependency] {
//        hasMacros ? [.target(name: macroName)] : []
//        hasMacros ? [.package(product: macroName, type: .runtime, condition: nil)] : []
        hasMacros ? [.package(product: macroName, type: .runtime, condition: nil)] : []
    }
    
    private func macrosTarget() -> Target {
        .target(name: name + "Macros",
                destinations: .macOS,
                product: .macro,
                bundleId: bundleId + ".macros",
                deploymentTargets: .macOS("15.0"),
                                                  
                sources: .sources(in: folderPrefix + "Macro/*/Sources/Macros"),
                dependencies: [
                    .package(product: "SwiftSyntax", type: .runtime, condition: nil),
                    .package(product: "SwiftCompilerPlugin", type: .runtime, condition: nil),
                    .package(product: "SwiftSyntaxBuilder", type: .runtime, condition: nil),
                    .package(product: "SwiftSyntaxMacros", type: .runtime, condition: nil)
                ]
        )
    }
    
    private func macroLibraryTarget() -> Target {
        .target(name: macroName,
                destinations: [.iPad, .iPhone, .macCatalyst, .macWithiPadDesign, .mac, .appleVision, .appleTv, .appleWatch],
                product: .staticLibrary,
                bundleId: bundleId + ".macros.lib",
                deploymentTargets: .multiplatform(iOS: "16.0", macOS: "15.0"),
                sources: .sources(in: folderPrefix + "Macro/*/Sources/Library"),
                dependencies: [
                    .macro(name: name + "Macros")
                ]
        )
    }
    
    private func macroLibraryTests() -> Target {
        .target(name: macroName + "Tests",
                destinations: .macOS,
                product: .unitTests,
                bundleId: bundleId + ".macros.tests",
                deploymentTargets: .macOS("15.0"),
                sources: .sources(in: folderPrefix + "Macro/*/Tests"),
                dependencies: [
                    .target(name: "\(name)Macros", status: .optional, condition: nil),
                    .package(product: "SwiftSyntaxMacrosTestSupport", type: .runtime, condition: nil)
                ]
        )
    }
    func swiftSyntax() -> Package {
        .package(url: "https://github.com/apple/swift-syntax", "600.0.0" ..< "700.0.0")
    }
    func macroPackages() -> [Package] {
        hasMacros ? [
            swiftSyntax(),
            .local(path: "./Macro")
        ] : []
    }
    func macroTargets() -> [Target] {
        [macroLibraryTarget(), macrosTarget(), macroLibraryTests()].filter { _ in hasMacros }
    }
    #else
    
    private var tuistMacro: Bool { true }
    
    private func macroDependency() -> [TargetDependency] {
        hasMacros ? [.external(name: macroName, condition: nil)] : []

    }
    func macroPackages() -> [Package] {
        []
    }
    func macroTargets() -> [Target] {
        []
    }
    #endif
    

    func testTarget(destinations: Destinations) -> Target {
        .target(name: testInfo().testTargetName,
                destinations: destinations,
                product: .unitTests,
                bundleId: bundleId + ".tests",
                deploymentTargets: deploymentTargets,
                infoPlist: .extendingDefault(with: [:]),
                sources: .sources(in: folderPrefix + "Tests"),
                resources: .resources(in: folderPrefix + "Tests"),
                scripts: [],
                dependencies: makeTestDependencies())
    }

    func demoAppTarget(platform: Platform, destinations: Destinations) -> Target? {
        switch platform {
        case .iOS:
            .target(name: testAppName(for: platform),
                    destinations: destinations,
                    product: .app,
                    productName: testAppName(for: platform),
                    bundleId: bundleId + ".testapp",
                    deploymentTargets: platform.deploymentTargets,
                    infoPlist: .extendingDefault(with: ["UILaunchStoryboardName": "LaunchScreen",
                                                        "UIApplicationSceneManifest":
                                                            ["UISceneConfigurations": [
                                                                "UIWindowSceneSessionRoleApplication": [[
                                                                    "UISceneClassName": "UIWindowScene",
                                                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                                                ]]
                                                            ]]]),
                    sources: .sources(in: folderPrefix + "TestApp"),
                    resources: .resources(in: folderPrefix + "TestApp"),
                    scripts: [].filter { _ in useSourcery },
                    dependencies: makeDependencies(),
                    settings: settings,
                    mergedBinaryType: .disabled, mergeable: false)
        default: nil
        }
    }

    func targets() -> [Target] {
        [mainTarget(destinations: destinations)] +

            [testTarget(destinations: destinations)]
            .filter { _ in self.isTestable } +

            destinations.platformDestinations
            .flatMap { platform, destinations in
                var targets = [Target]()
                if hasDemoApp, let demoApp = demoAppTarget(platform: platform, destinations: destinations) {
                    targets += [demoApp]
                }
                return targets
            }
    }

    func project() -> Project {
        Project(
            name: name,
            packages: macroPackages(),
            settings: settings ?? .settings(base: ["SWIFT_VERSION": .string(swiftVersion.description)]),
            targets: targets() + macroTargets(),
            schemes: [name]
                .map { text in
                    .scheme(name: text,
                            buildAction: .buildAction(targets: ["\(text)"]),
                            testAction: .targets([.testableTarget(target: "\(text)Tests",
                                                                  parallelization: supportsParallelTesting ? .enabled : .disabled)],
                                                 options: .options(coverage: true, codeCoverageTargets: ["\(text)"])),
                            runAction: .runAction(configuration: .debug),
                            archiveAction: .archiveAction(configuration: .release),
                            analyzeAction: .analyzeAction(configuration: .debug))
                },
            resourceSynthesizers: [.plists()] + synthesizers
        )
    }

    func testInfo(for _: PlatformFilter) -> Skeleton.TestInfo {
        .init(isTestable: isTestable,
              isParallel: supportsParallelTesting,
              targetName: name)
    }

    func makeDependencies() -> [TargetDependency] {
        Array(dependencies.make())
    }

    func makeTestDependencies() -> [TargetDependency] {
        [makeDependency()].compactMap { $0 }
            + makeDependencies()
            + testDependencies.make()
            + [.sdk(name: "XCTest", type: .framework),
               .sdk(name: "Testing", type: .framework)]
    }
}

extension Array<any DependencyBuilder> {
    func uniqued() -> Array<any DependencyBuilder> {
        var values = [any DependencyBuilder]()
        for value in self {
            if let module = value as? ProjectConvertible {
                if !values.contains(where: { ($0 as? ProjectConvertible)?.path == module.path }) {
                    values.append(value)
                }
            } else {
                values.append(value)
            }
        }
        return values
    }
}
