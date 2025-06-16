import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct LibraryPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [CaseMacro.self]
}

