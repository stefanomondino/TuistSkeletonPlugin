import ProjectDescription
import SkeletonPlugin

public extension Skeleton.CoreModule {
    static func logger() -> Skeleton.CoreModule {
        Skeleton.CoreModule(name: "Logger", destinations: Constants.destinations,
                            deploymentTargets: .custom,
                            swiftVersion: .v6,
                            testDependencies: .init(test: [.coreTesting()]),
                            synthesizers: [])
    }
}
