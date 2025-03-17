//
//  SkeletonModule.swift
//  ProjectDescriptionHelpers
//
//  Created by Andrea Altea on 24/01/24.
//

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
    var swiftVersion: SwiftVersion { get }
    func mainTarget(destinations: Destinations) -> Target
    func testTarget(destinations: Destinations) -> Target
    func demoAppTarget(platform: Platform, destinations: Destinations) -> Target?
}

public extension SkeletonModule {
//    var deploymentTargets: ProjectDescription.DeploymentTargets {
//        .multiplatform(
//            iOS: "15.0"
    ////            macOS: "13.0",
    ////            watchOS: "7.0",
    ////            tvOS: "15.0",
    ////            visionOS: "1.0"
//        )
//    }

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
                scripts: [.sourcery()].filter { _ in useSourcery },
                dependencies: makeDependencies(),
                settings: settings,
                mergedBinaryType: .disabled, mergeable: false)
    }

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
            settings: settings ?? .settings(base: ["SWIFT_VERSION": .string(swiftVersion.description)]),
            targets: targets(),
            schemes: [name]
                .map { text in
                    .scheme(name: text,
                            buildAction: .buildAction(targets: ["\(text)"]),
                            testAction: .targets([.testableTarget(target: "\(text)Tests",
                                                                  isParallelizable: supportsParallelTesting)],
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
            + [.sdk(name: "XCTest", type: .framework)]
    }
}
