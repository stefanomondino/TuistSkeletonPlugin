import ProjectDescription

private extension Platform {
    var exclusions: [String] {
        var allButSelf = Set(Platform.allCases)
        allButSelf.remove(self)
        return allButSelf.map { "\($0)" }
    }
}

public extension SourceFilesList {
    static func sources(in folder: String) -> SourceFilesList {
        .sources(in: [folder])
    }
    
    static func sources(in folders: [String]) -> SourceFilesList {
        .sourceFilesList(globs: folders
            .flatMap { folder in
                [.glob("\(folder)/**/*.swift")] +
                Platform.allCases.flatMap { platform -> [ProjectDescription.SourceFileGlob] in
                    [.glob("\(folder)/**/*.\(platform)/**/*.swift", compilationCondition: .when(platform.filters)),
                     .glob("\(folder)/**/*.\(platform).swift", compilationCondition: .when(platform.filters))]
                }
            })
    }
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
    
    static func resources(in folder: String) -> ResourceFileElements {
        resources(in: [folder])
    }

    static func resources(in folders: [String]) -> ResourceFileElements {
        .resources(folders
            .flatMap { folder in
                Platform.allCases.map { (folder, $0) }
            }
            .flatMap { folder, platform in
                [.glob(pattern: "\(folder)/**",
                       excluding: ["**/*.swift",
                                   "*.swift",
                                   "**/*.entitlements",
                                   "**/*.xcodeproj/**"] + platform.exclusions.flatMap { ["\(folder)/**/*.swift",
                                                                                         "\(folder)/**/*.\($0)/**"] },
                       inclusionCondition: .when(platform.filters))]
            })
    }
    
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
