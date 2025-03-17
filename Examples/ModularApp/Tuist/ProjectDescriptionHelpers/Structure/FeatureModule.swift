import ProjectDescription
import SkeletonPlugin

public extension Skeleton {
    struct FeatureModule: SkeletonModule {
        public struct Dependencies: ModuleDependencies {
            public var isPrivate: Bool
            public var core: [CoreModule]
            public var bridge: [BridgeModule]
            public var external: [ExternalModule]
            public var dependencies: [DependencyBuilder] { core + bridge }
            public init(isPrivate: Bool = false,
                        core: [CoreModule] = [],
                        bridge: [BridgeModule] = [],
                        external: [ExternalModule] = []) {
                self.isPrivate = isPrivate
                self.core = core
                self.bridge = bridge
                self.external = external
            }
        }

        public var path: ProjectDescription.Path { "Sources/Features/\(name)" }
        public var name: String
        public var swiftVersion: SwiftVersion
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
        public var supportsParallelTesting: Bool
        public var hasDemoApp: Bool

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
            self.swiftVersion = swiftVersion
            self.product = product.product
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
                .project(target: "\(name)",
                         path: "../../Features/\(name)",
                         condition: .when(deploymentTargets.filters))
            } else {
                .target(name: name, condition: .when(deploymentTargets.filters))
            }
        }
    }
}
