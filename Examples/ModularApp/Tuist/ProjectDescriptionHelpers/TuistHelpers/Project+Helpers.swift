import ProjectDescription

private extension Platform {
    var exclusions: [String] {
        var allButSelf = Set(Platform.allCases)
        allButSelf.remove(self)
        return allButSelf.map { "\($0)" }
    }
}

public extension SourceFilesList {
    static func sources(in folder: String, platform: Platform) -> SourceFilesList {
        .sources(in: [folder], platform: platform)
    }

    static func sources(in folders: [String], platform: Platform) -> SourceFilesList {
        .sourceFilesList(globs: folders.map { folder in
            .glob("\(folder)/**/*.swift",
                  excluding: platform.exclusions
                      .flatMap { ["\(folder)/**/*.\($0)/**/*.swift",
                                  "\(folder)/**/*.\($0).swift"] })
        })
    }
}

public extension ResourceFileElements {
    static func resources(in folder: String, platform: Platform) -> ResourceFileElements {
        resources(in: [folder], platform: platform)
    }

    static func resources(in folders: [String], platform: Platform) -> ResourceFileElements {
        .resources(folders.flatMap { folder in
            [.glob(pattern: "\(folder)/**",
                   excluding: ["**/*.swift",
                               "**/*.entitlements",
                               "**/*.xcodeproj/**"
//                              "**/*.environment"
                   ] + platform.exclusions.flatMap { ["\(folder)/**/*.\($0).swift",
                                                      "\(folder)/**/*.\($0)/**"] })
//            .folderReference(path: "\(folder)/Environments"),
            ]
        })
    }
}

public typealias PlatformDependencies = (Platform) -> [TargetDependency]
public extension Project {
//    static var platforms: [Platform] {
//        Constants.platforms
//    }

    /// A simple framework implementing a very specific feature
//    static func featureFramework(name: String,
//                                 platforms: [Platform] = platforms,
//                                 dependencies: PlatformDependencies = { _ in [] },
//                                 testDependencies: PlatformDependencies = { _ in [] },
//                                 settings: Settings? = nil,
//                                 useSourcery: Bool = false,
//                                 synthesizers: [ResourceSynthesizer] = []) -> Project {
//        let targets: [Target] = platforms.map { platform in
//            .customTarget(name: name,
//                          platform: platform,
//                          dependencies: Array(Set(dependencies(platform))),
//                          settings: settings,
//                          useSourcery: useSourcery)
//        }
//
//        let testTargets: [Target] = platforms.map { platform in
//            .customTestTarget(name: name,
//                              platform: platform,
//                              dependencies: Array(Set(dependencies(platform) + testDependencies(platform) + TargetDependency.testDependencies(for: platform))))
//        }
//
//        return Project(
//            name: name,
    ////            settings: .projectSettings,
//            targets: targets + testTargets,
//            schemes: platforms
//                .map { "\(name)_\($0)" }
//                .map { text in
//                    .init(name: text,
//                          buildAction: .buildAction(targets: ["\(text)"]),
//                          testAction: .targets([.init(target: "\(text)Tests", parallelizable: true)],
//                                               options: .options(coverage: true)),
//                          analyzeAction: .analyzeAction(configuration: .debug))
//                },
//            resourceSynthesizers: [.plists(), .fonts()] + synthesizers
//        )
//    }
//
//    /// A complex framework implementing an entire part of the app
//    static func moduleFramework(name: String,
//                                moduleName: String? = nil,
//                                platforms: [Platform] = platforms,
//                                dependencies: PlatformDependencies = { _ in [] },
//                                testDependencies: PlatformDependencies = { _ in [] },
//                                settings: Settings? = nil) -> Project {
//        let moduleName = moduleName ?? name
//        let targets = platforms.map { platform -> [Target] in
//
//            [.customTarget(name: name,
//                           moduleName: moduleName,
//                           platform: platform,
//                           dependencies: Array(Set(dependencies(platform))),
//                           settings: settings,
//                           useSourcery: true),
//             .customTestTarget(name: name,
//                               platform: platform,
//                               dependencies: Array(Set(testDependencies(platform) + TargetDependency.moduleTestDependencies(for: platform))),
//                               useSourcery: false)]
//        }
//        return Project(
//            name: name,
    ////            settings: .projectSettings,
//            targets: targets.flatMap { $0 },
//            schemes: platforms
//                .map { "\(name)_\($0)" }
//                .map { text in
//                    .init(name: text,
//                          buildAction: .buildAction(targets: ["\(text)"]),
//                          testAction: .targets(["\(text)Tests"], options: .options(coverage: true)),
//                          analyzeAction: .analyzeAction(configuration: .debug))
//                },
//            resourceSynthesizers: [.plists(), .assets(), .fonts()]
//        )
//    }
}

public extension TargetDependency {
    private static func project(named name: String,
                                platform: Platform) -> TargetDependency {
        .project(target: "\(name)_\(platform)", path: "../../Core/\(name)")
    }

    static func core(_ platform: Platform) -> TargetDependency {
        .project(named: "SharedModel", platform: platform)
    }

    static func networking(_ platform: Platform) -> TargetDependency {
        .project(named: "Networking", platform: platform)
    }

    static func designSystem(_ platform: Platform) -> TargetDependency {
        .project(named: "DesignSystem", platform: platform)
    }

    static func logger(_ platform: Platform) -> TargetDependency {
        .project(named: "Logger", platform: platform)
    }

    static func routes(_ platform: Platform) -> TargetDependency {
        .project(named: "Routes", platform: platform)
    }

    static func forms(_ platform: Platform) -> TargetDependency {
        .project(named: "Forms", platform: platform)
    }

    static func tracking(_ platform: Platform) -> TargetDependency {
        .project(named: "Tracking", platform: platform)
    }

    static func components(_ platform: Platform) -> TargetDependency {
        .project(named: "Components", platform: platform)
    }

    static func storage(_ platform: Platform) -> TargetDependency {
        .project(named: "Storage", platform: platform)
    }

    static func forgeClient(_ platform: Platform) -> TargetDependency {
        .project(named: "ForgeClient", platform: platform)
    }

    static func forgeComponents(_ platform: Platform) -> TargetDependency {
        .project(target: "ForgeComponents_\(platform)", path: "../ForgeComponents")
    }

    static func sportClient(_ platform: Platform) -> TargetDependency {
        .project(named: "SportClient", platform: platform)
    }

    static func videoPlayer(_ platform: Platform) -> TargetDependency {
        .project(named: "VideoPlayer", platform: platform)
    }

    static func videos(_ platform: Platform) -> TargetDependency {
        .project(target: "Videos_\(platform)", path: "../Videos")
    }

    static func pushNotifications(_ platform: Platform) -> TargetDependency {
        .project(named: "PushNotifications", platform: platform)
    }

    static func nightwatchClient(_ platform: Platform) -> TargetDependency {
        .project(named: "NightwatchClient", platform: platform)
    }
    // murray: utility
}
