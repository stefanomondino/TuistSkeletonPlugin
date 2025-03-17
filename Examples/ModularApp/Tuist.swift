import Foundation
import ProjectDescription

let config = Config(project: .tuist(plugins: [
                                        // .git(url: "https://github.com/stefanomondino/TuistSkeletonPlugin",
                                                //    tag: "main")
                                       .local(path: "../../../")
                                    ],
                                    generationOptions: .options(),
                                    installOptions: .options()))

// Unfortunately this cannot be embedded in the plugin because it's used in the same place where the plugin is loaded.
public extension CompatibleXcodeVersions {
    static var xcodes: CompatibleXcodeVersions {
        let xcodeVersionData = FileManager.default.contents(atPath: ".xcode-version") ?? Data()
        let xcodeVersionString = String(data: xcodeVersionData, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let xcodeVersionObject = ProjectDescription.Version(string: xcodeVersionString)
        if let xcodeVersionObject {
            return .exact(xcodeVersionObject)
        } else {
            return .all
        }
    }
}