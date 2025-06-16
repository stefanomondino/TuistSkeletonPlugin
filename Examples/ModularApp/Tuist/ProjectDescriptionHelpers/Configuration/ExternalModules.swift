import ProjectDescription
import SkeletonPlugin

extension Skeleton.ExternalModule {

    static func kingfisher() -> Skeleton.ExternalModule {
        .external(name: "Kingfisher")
    }

    static func keychainAccess() -> Skeleton.ExternalModule {
        .external(name: "KeychainAccess", isPrivate: true)
    }

    static func asyncAlgorithms() -> Skeleton.ExternalModule {
        .external(name: "AsyncAlgorithms")
    }
}
