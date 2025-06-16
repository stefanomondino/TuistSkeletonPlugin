import Testing
import SwiftSyntaxMacrosTestSupport
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import DataStructuresMacros

@Suite("DataStructures Macros tests")
public struct DataStructuresMacroTests {
    @Test("Expansion works")
    func test1() {
        let source: SourceFileSyntax =
            """
            struct Key: ExtensibleIdentifierType, ExpressibleByStringInterpolation {
                let value: String
                
                init(_ value: String) {
                    self.value = value
                }
            
                @Case static var test: Self
            
                @Case("ciao") static var test2: Self
            }
            """


        let file = BasicMacroExpansionContext.KnownSourceFile(
            moduleName: "MyModule",
            fullFilePath: "test.swift"
        )


        let context = BasicMacroExpansionContext(sourceFiles: [source: file])
        
        let transformedSF = source.expand(
            macros:["Case": CaseMacro.self],
            in: context
        )


        let expectedDescription =
            """
            struct Key: ExtensibleIdentifierType, ExpressibleByStringInterpolation {
                let value: String
                
                init(_ value: String) {
                    self.value = value
                }

                static var test: Self {
                    get {
                        .init("test")
                    }
                }

                static var test2: Self {
                    get {
                        .init("ciao")
                    }
                }
            }
            """
        print(transformedSF.description)
        print(expectedDescription)
        #expect(transformedSF.description == expectedDescription)
    }
}

