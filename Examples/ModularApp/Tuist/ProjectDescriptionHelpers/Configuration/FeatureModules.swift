import ProjectDescription
import SkeletonPlugin

public extension Skeleton.FeatureModule {

    static func onboarding() -> Skeleton.FeatureModule {
        Skeleton.FeatureModule(name: "Onboarding",
                               destinations: Constants.destinations,
                               deploymentTargets: .custom,
                               dependencies: .init(core: [.designSystem()],
                                                   bridge: [],
                                                   external: [.kingfisher()]),
                               testDependencies: .init(test: [.coreTesting()]),
                               synthesizers: [])
    }
}
