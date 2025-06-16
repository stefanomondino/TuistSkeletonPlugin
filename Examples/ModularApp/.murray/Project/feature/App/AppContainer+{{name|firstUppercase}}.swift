{{_fileHeader}}

import DependencyContainer
import Foundation
import SharedModel
import Routes
import ToolKit

#if canImport({{name|firstUppercase}})
import {{name|firstUppercase}}

extension EnvironmentImplementation: {{name|firstUppercase}}.FeatureEnvironment {}

extension AppContainer: {{name|firstUppercase}}.FeatureContainer {
    
    func {{name|firstLowercase}}() async -> {{name|firstUppercase}}.Feature<AppContainer> { await unsafeResolve() }
    
    func setup{{name|firstUppercase}}() async {

        await register(for: {{name|firstUppercase}}.FeatureEnvironment.self) {
                await self.environment
        }
        await register(scope: .eagerSingleton) {
            await {{name|firstUppercase}}.Feature(self)
        }
    }
}
#else
extension AppContainer {
    func setup{{name|firstUppercase}}() async {}
}
#endif