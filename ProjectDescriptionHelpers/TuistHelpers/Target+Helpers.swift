import ProjectDescription

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
