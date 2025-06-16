import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CaseMacro {
    struct CustomError: Error, CustomStringConvertible {
        let description: String
        init(_ description: String) { self.description = description }
    }
    
    public init() {}
}

extension CaseMacro: AccessorMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
//        let extensionType = context.lexicalContext.first?
//            .as(ExtensionDeclSyntax.self)?.extendedType
//            .as(IdentifierTypeSyntax.self)
        // Ensure the macro is applied inside a type that conforms to ExtensibleIdentifierType
//        guard let parent = declaration.parent else {
//            throw CustomError("Case macro must be used inside a type.")
//        }
//
//        // Try to cast to a supported type declaration
//        let conforms: Bool = {
//            if let structDecl = parent.as(StructDeclSyntax.self),
//               let inheritanceClause = structDecl.inheritanceClause {
//                return inheritanceClause.inheritedTypes.contains { $0.type.trimmedDescription == "ExtensibleIdentifierType" }
//            }
//            if let classDecl = parent.as(ClassDeclSyntax.self),
//               let inheritanceClause = classDecl.inheritanceClause {
//                return inheritanceClause.inheritedTypes.contains { $0.type.trimmedDescription == "ExtensibleIdentifierType" }
//            }
//            if let enumDecl = parent.as(EnumDeclSyntax.self),
//               let inheritanceClause = enumDecl.inheritanceClause {
//                return inheritanceClause.inheritedTypes.contains { $0.type.trimmedDescription == "ExtensibleIdentifierType" }
//            }
//            return false
//        }()
//
//        guard conforms else {
//            throw CustomError("Case macro can only be used in types conforming to ExtensibleIdentifierType")
//        }


        
//        guard extensionType?.name.text == "ExtensibleIdentifierType" else {
//            throw MacroExpansionErrorMessage("Resolved macro must be applied to ExtensibleIdentifierType")
//        }
        
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("Not a variable")
        }
        
            
        guard let identifier = varDecl.bindings.first?.pattern else {
            throw MacroExpansionErrorMessage("Unable to resolve variable identifier")
        }
        let id: String
        if case .argumentList(let args) = node.arguments,
           let expression = args.first?.expression,
           expression.description.isEmpty == false {
            id = expression.trimmedDescription
        }
        else {
            id = "\"\(identifier.trimmedDescription)\""
        }
        
        let getAccessor = AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
            ".init(\(raw: id))"
        }

        return [getAccessor]
    }
}
