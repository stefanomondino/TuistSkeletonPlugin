{{ fileHeader }}

import Components
import ToolKit
import DesignSystem
import Routes
import UIKit

public class Module: Boomerang.SharedDependencyContainer {
    @Dependency public var routes: SharedRouteFactory

    public init() {
        registerRepositories()
        registerUseCases()

        environment = resolve(Environment.self) ?? EnvironmentMock()

        register(for: RouteFactory.self, scope: .singleton) {
            RouteFactoryImplementation()
        }

        register(for: SharedRouteFactory.self, scope: .singleton) { [self] in
            unsafeResolve(RouteFactory.self)
        }

        register(for: SceneViewModelFactory.self, scope: .singleton) {
            SceneViewModelFactory()
        }

        register(for: ComponentViewModelFactory.self, scope: .singleton) {
            ComponentViewModelFactory()
        }

        register(for: SceneFactory.self, scope: .singleton) {
            SceneFactory(components: self.unsafeResolve())
        }

        register(for: ComponentFactory.self, scope: .singleton) {
            ComponentFactoryImplementation()
        }
    }
}
