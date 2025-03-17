import ProjectDescription

public extension Skeleton {
    struct ExternalModule: DependencyBuilder {
        private struct EmptyModuleDependencies: ModuleDependencies {
            var dependencies: [DependencyBuilder] { [] }
            var isPrivate: Bool { true }
            var external: [Skeleton.ExternalModule] { [] }
        }

        enum TargetType {
            case none
            case external(name: String, condition: ProjectDescription.PlatformCondition? = nil)
            case sdk(name: String, type: ProjectDescription.SDKType, condition: ProjectDescription.PlatformCondition? = nil)
        }

        let targetType: TargetType
        let isPrivate: Bool

        public static func external(name: String,
                                    condition: ProjectDescription.PlatformCondition? = nil,
                                    isPrivate: Bool = false) -> Self {
            .init(.external(name: name, condition: condition), isPrivate: isPrivate)
        }

        public static var none: Self {
            .init(.none, isPrivate: true)
        }

        public static func sdk(name: String,
                               type: ProjectDescription.SDKType,
                               condition: ProjectDescription.PlatformCondition? = nil,
                               isPrivate: Bool = false) -> Self {
            .init(.sdk(name: name, type: type, condition: condition), isPrivate: isPrivate)
        }

        init(_ targetType: TargetType, isPrivate: Bool) {
            self.targetType = targetType
            self.isPrivate = isPrivate
        }

        public var dependencies: ModuleDependencies { EmptyModuleDependencies() }
        public func makeDependency() -> TargetDependency? {
            switch targetType {
            case .none:
                nil
            case let .external(name, condition):
                .external(name: name, condition: condition)
            case let .sdk(name, type, condition):
                .sdk(name: name, type: type, condition: condition)
            }
        }
    }
}
