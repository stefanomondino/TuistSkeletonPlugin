{{ fileHeader }}

import Foundation
#if canImport({{name|firstUppercase}})
    import {{name|firstUppercase}}

    extension EnvironmentImplementation: {{name|firstUppercase}}.Environment {}
    
    extension AppContainer {
        var {{name|firstLowercase}}: {{name|firstUppercase}}.Module { unsafeResolve() }

        func setup{{name|firstUppercase}}() {
            register(for: {{name|firstUppercase}}.Environment.self) {
                self.environment
            }
            register(for: {{name|firstUppercase}}.Module.self, scope: .eagerSingleton) {
                .init()
            }
        }
    }

#endif
