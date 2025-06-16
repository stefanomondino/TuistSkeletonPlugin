{{ fileHeader }}

import ToolKit
import Components
import DependencyContainer
import DesignSystem
import Routes
import SharedModel
import UIKit

public final class Module: SharedDependencyContainer {
    public init() {
        registerRepositories()
        registerUseCases()

        environment = resolve(Environment.self) ?? EnvironmentMock()

        register(for: SceneViewModelFactory.self, scope: .singleton) {
            SceneViewModelFactory()
        }

        register(for: ComponentViewModelFactory.self, scope: .singleton) {
            ComponentViewModelFactory()
        }

        registerRoutes(routeContainer: unsafeResolve(),
                       viewModels: unsafeResolve())
    }
}
