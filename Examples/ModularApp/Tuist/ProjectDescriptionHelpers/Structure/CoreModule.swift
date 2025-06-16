import ProjectDescription
import SkeletonPlugin

public extension Skeleton {
    struct CoreModule: SkeletonModule {
        public struct Dependencies: ModuleDependencies {
            public var isPrivate: Bool
            public var core: [CoreModule]
            public var block: [BlockModule]
            public var external: [ExternalModule]
            public var dependencies: [DependencyBuilder] { core + block + external }

            public init(isPrivate: Bool = false,
                        block: [BlockModule] = [],
                        core: [CoreModule] = [],
                        external: [ExternalModule] = []) {
                self.isPrivate = isPrivate
                self.core = core
                self.block = block
                self.external = external
            }
        }

        public var path: ProjectDescription.Path { "Sources/Core/\(folderName)" }
        public var swiftVersion: SwiftVersion
        public var name: String
        public var folderName: String
        public var destinations: Destinations
        public var deploymentTargets: DeploymentTargets
        public var dependencies: ModuleDependencies
        public var testDependencies: ModuleDependencies
        public var settings: Settings?
        public var synthesizers: [ResourceSynthesizer]
        public var product: Product
        public var useSourcery: Bool
        public var isTestable: Bool
        public var hasDemoApp: Bool
        public var supportsParallelTesting: Bool
        public init(name: String,
                    folderName: String? = nil,
                    destinations: Destinations,
                    deploymentTargets: DeploymentTargets,
                    product: ProjectDefinition.Product = .automaticFramework,
                    swiftVersion: SwiftVersion = .default,
                    dependencies: Dependencies = .init(),
                    testDependencies: TestDependencies = .init(),
                    settings: Settings? = nil,
                    synthesizers: [ResourceSynthesizer],
                    useSourcery: Bool = true,
                    isTestable: Bool = true,
                    supportsParallelTesting: Bool = true,
                    hasDemoApp: Bool = false) {
            self.name = name
            self.product = product.product
            self.swiftVersion = swiftVersion
            self.folderName = folderName ?? name
            self.destinations = destinations
            self.deploymentTargets = deploymentTargets
            self.dependencies = dependencies
            self.testDependencies = testDependencies
            self.settings = settings
            self.synthesizers = synthesizers
            self.useSourcery = useSourcery
            self.isTestable = isTestable
            self.supportsParallelTesting = supportsParallelTesting
            self.hasDemoApp = hasDemoApp
        }

        public func makeDependency() -> TargetDependency? {
            if createProject {
                .project(target: name,
                         path: "../../Core/\(folderName)",
                         condition: .when(deploymentTargets.filters))
            } else {
                .target(name: name, condition: .when(deploymentTargets.filters))
            }
        }
    }
}
