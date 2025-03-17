import Foundation
import SkeletonPlugin

public extension Skeleton.TestModule {
    static func coreTesting() -> Skeleton.TestModule {
        Skeleton.TestModule(name: "CoreTesting",
                            destinations: Constants.destinations,
                            deploymentTargets: .custom,
                            dependencies: .init(core: [],
                                                external: [.sdk(name: "XCTest", type: .framework)]))
    }
}
