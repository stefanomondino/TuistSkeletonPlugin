//
//  TestModule.swift
//  ProjectDescriptionHelpers
//
//  Created by Andrea Altea on 24/01/24.
//

import ProjectDescription

public extension Skeleton {
    struct TestModule: ProjectConvertible, DependencyBuilder {
        public struct Dependencies: ModuleDependencies {
            public var isPrivate: Bool { true }
            public var core: [DependencyBuilder]
            public var test: [TestModule]
            public var external: [ExternalModule]
            public var dependencies: [DependencyBuilder] { core + test }
            public init(core: [DependencyBuilder] = [],
                        test: [TestModule] = [],
                        external: [ExternalModule] = []) {
                self.core = core
                self.test = test
                self.external = external
            }
        }

        public var name: String
        public var path: Path
        public var destinations: Destinations
        public var deploymentTargets: DeploymentTargets
        public var dependencies: ModuleDependencies
        public var isTestable: Bool { false }
        public var supportsParallelTesting: Bool { false }
        public init(name: String,
                    destinations: Destinations,
                    deploymentTargets: DeploymentTargets,
                    dependencies: Dependencies,
                    path: (String) -> Path = { "Sources/Testing/\($0)" }) {
            self.name = name
            self.path = path(name)
            self.destinations = destinations
            self.deploymentTargets = deploymentTargets
            self.dependencies = dependencies
        }

        var bundleId: String {
            "app.\(name.lowercased())"
        }

        public func targets() -> [Target] {
            [Target.target(name: name,
                           destinations: destinations,
                           product: .framework,
                           productName: name,
                           bundleId: bundleId,
                           deploymentTargets: deploymentTargets,
                           infoPlist: .extendingDefault(with: [:]),
                           sources: .sources(in: folderPrefix + "Sources"),
                           resources: .resources(in: folderPrefix + "Sources"),
                           scripts: [],
                           dependencies: Array(dependencies.make()),
                           settings: .none,
                           mergedBinaryType: .disabled,
                           mergeable: false)]
        }

        public func project() -> Project {
            Project(
                name: name,
                options: .options(),
                targets: targets()
            )
        }

        public func makeDependency() -> TargetDependency? {
            if createProject {
                .project(target: name,
                         path: "../../Testing/\(name)",
                         condition: .when(deploymentTargets.filters))
            } else {
                .target(name: name,
                        condition: .when(deploymentTargets.filters))
            }
        }
    }
}
