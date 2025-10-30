import ProjectDescription

public typealias Platforms = Set<Platform>

public enum Skeleton {
    enum Error: Swift.Error {
        case platformNotSupported
    }
}

public extension Skeleton {
    struct TestInfo {
        var isTestable: Bool
        var isParallel: Bool
        var targetName: String
        var testTargetName: String { targetName + "Tests" }
        public static var none: Self { .init(isTestable: false, targetName: "") }
        init(isTestable: Bool,
             isParallel: Bool = true,
             targetName: String) {
            self.isTestable = isTestable
            self.isParallel = isParallel
            self.targetName = targetName
        }
    }
}

public protocol ProjectConvertible: Sendable {
    var path: Path { get }
    var supportsParallelTesting: Bool { get }
    var name: String { get }
    var isTestable: Bool { get }
    var hasMacros: Bool { get }
    func testInfo() -> Skeleton.TestInfo
    var destinations: Destinations { get }
    var createProject: Bool { get }
    func project() -> Project
    func targets() -> [Target]
}

public extension ProjectConvertible {
    var createProject: Bool { true }
    var hasMacros: Bool { false }
    var folderPrefix: String {
        if createProject {
            ""
        } else {
            "\(path.pathString)/"
        }
    }

    func testInfo() -> Skeleton.TestInfo {
        .init(isTestable: isTestable,
              isParallel: supportsParallelTesting,
              targetName: name)
    }
}

public protocol DependencyBuilder: Sendable {
    var dependencies: ModuleDependencies { get }
    func makeDependency() -> TargetDependency?
}

public protocol ModuleDependencies: Sendable {
    var dependencies: [DependencyBuilder] { get }
    var isPrivate: Bool { get }
    var external: [Skeleton.ExternalModule] { get }
    func make() -> Set<TargetDependency>
}

public extension ModuleDependencies {
    private var recursiveDependencies: Bool {
        if ProjectDescription.Environment.skipRecursiveDependencies == .string("1") {
            return false
        }
        return true
    }

    func make(skipIfPrivate: Bool) -> Set<TargetDependency> {
        if skipIfPrivate, isPrivate { return [] }
        return Set(dependencies.uniqued()
            .flatMap {
                if recursiveDependencies {
                    [$0.makeDependency()].compactMap { $0 } +
                    $0.dependencies.make(skipIfPrivate: true)
                } else {
                    [$0.makeDependency()].compactMap { $0 }
                }
            }
            + external.compactMap {
                if skipIfPrivate, $0.isPrivate { return nil }
                return $0.makeDependency()
            })
    }

    func make() -> Set<TargetDependency> {
        make(skipIfPrivate: false)
    }
}

public protocol AppEnvironment: Encodable, Equatable, Sendable {
    var name: String { get }
}

public protocol AppModule: ProjectConvertible, Encodable {
    associatedtype Environment: AppEnvironment

    var name: String { get }
    var folder: String { get }
    var environments: [Environment] { get }
}

public extension Platform {
    var packagePlatform: PackagePlatform {
        switch self {
        case .iOS: .iOS
        case .macOS: .macOS
        case .tvOS: .tvOS
        case .visionOS: .visionOS
        case .watchOS: .watchOS
        @unknown default:
            fatalError()
        }
    }

    var deploymentTargets: DeploymentTargets {
        switch self {
        case .macOS: .macOS("13.0")
        case .watchOS: .watchOS("7.0")
        case .tvOS: .tvOS("15.0")
        case .visionOS: .visionOS("1.0")
        case .iOS: .iOS("15.0")
        @unknown default:
            fatalError()
        }
    }

    var filters: Set<PlatformFilter> {
        switch self {
        case .iOS: [.ios, .catalyst]
        case .macOS: [.macos]
        case .tvOS: [.tvos]
        case .visionOS: [.visionos]
        case .watchOS: [.watchos]
        @unknown default:
            fatalError()
        }
    }
}

public extension Collection<Destination> {
    var platforms: Platforms {
        reduce(into: Set<Platform>()) { partialResult, destination in
            partialResult.insert(destination.platform)
        }
    }

    var platformFilters: PlatformFilters {
        platforms.reduce(into: PlatformFilters()) { partialResult, platform in
            for filter in platform.filters {
                partialResult.insert(filter)
            }
        }
    }

    var platformDestinations: [Platform: Destinations] {
        reduce(into: [Platform: Destinations]()) { partialResult, destination in
            partialResult.insertValue(for: destination.platform, value: destination)
        }
    }

    var packagePlatforms: Set<PackagePlatform> {
        platforms.reduce(into: Set<PackagePlatform>()) { partialResult, platform in
            partialResult.insert(platform.packagePlatform)
        }
    }
}

private extension Dictionary {
    mutating func insertValue<Element: Equatable>(for key: Key, value: Element) where Value == Set<Element> {
        guard var set = self[key] else {
            self[key] = Set([value])
            return
        }
        set.insert(value)
        self[key] = set
    }
}
