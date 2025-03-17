import ProjectDescription

public extension Platform {
//    var deploymentTarget: DeploymentTarget {
//        switch self {
//        case .iOS: return .iOS(targetVersion: Constants.iOSDeploymentTarget,
//                               devices: [.ipad, .iphone, .mac])
//        case .macOS: return .macOS(targetVersion: Constants.macOSDeploymentTarget)
//        case .watchOS: return .watchOS(targetVersion: "7.0")
//        case .tvOS: return .tvOS(targetVersion: "")
//        case .visionOS: return .visionOS(targetVersion: "")
//        @unknown default:
//            fatalError()
//        }
//    }
}

private extension String {
    func miseCommand() -> String {
        #"eval "$(~/.local/bin/mise activate bash)" && mise exec \#(components(separatedBy: " ").first ?? self) -- \#(self)"#
    }
}

public extension TargetScript {
    static func sourcery(config: String = "sourcery.yml") -> Self {
        .pre(script: """
             if [ -f "./\(config)" ]; then
             \("sourcery --config \(config)".miseCommand())
             fi
             """,
             name: "Sourcery",
             basedOnDependencyAnalysis: false)
    }

    static func swiftlint(in path: String = "../../..") -> Self {
        .pre(script: "cd \(path) && \("swiftlint".miseCommand())",
             name: "Swiftlint",
             basedOnDependencyAnalysis: false)
    }
}

public extension Target {
//    static func customTarget(name: String,
//                             moduleName: String? = nil,
//                             platform: Platform,
//                             product: Product = .framework,
//                             bundleId: String? = nil,
//                             folder _: String = "Sources",
//                             dependencies: [TargetDependency] = [],
//                             settings: Settings?,
//                             useSourcery: Bool = false) -> Target {
//        Target(name: "\(name)_\(platform)",
//               platform: platform,
//               product: product,
//               productName: moduleName ?? name,
//               bundleId: bundleId ?? "app.framework.\(name).\(platform)",
//               deploymentTarget: platform.deploymentTarget,
//               infoPlist: .extendingDefault(with: [:]),
//               sources: .sources(in: "Sources", platform: platform),
//               resources: .resources(in: "Sources", platform: platform),
//               scripts: [.sourcery()].filter { _ in useSourcery },
//               dependencies: dependencies,
//               settings: settings)
//    }
//
//    static func customTestTarget(name: String,
//                                 moduleName: String? = nil,
//                                 platform: Platform,
//                                 bundleId: String? = nil,
//                                 dependencies: [TargetDependency] = [],
//                                 useSourcery: Bool = false) -> Target {
//        Target(name: "\(name)_\(platform)Tests",
//               platform: platform,
//               product: .unitTests,
//               bundleId: bundleId ?? "app.framework.\(name).\(platform).tests",
//               deploymentTarget: platform.deploymentTarget,
//               infoPlist: .extendingDefault(with: [:]),
//               sources: .sources(in: "Tests", platform: platform),
//               resources: .resources(in: "Tests", platform: platform),
//               scripts: [.sourcery(config: "sourceryTests.yml")].filter { _ in useSourcery },
//
//               dependencies: dependencies + [.target(name: moduleName ?? "\(name)_\(platform)")])
//    }
}

extension DeploymentTargets {
    static var custom: DeploymentTargets {
        // .multiplatform(iOS: Constants.iOSDeploymentTarget
//                       macOS: Constants.macOSDeploymentTarget,
//                       watchOS: "7.0",
//                       tvOS: Constants.iOSDeploymentTarget,
//                       visionOS: "1.0"
        // )
        .iOS(Constants.iOSDeploymentTarget)
    }
}
