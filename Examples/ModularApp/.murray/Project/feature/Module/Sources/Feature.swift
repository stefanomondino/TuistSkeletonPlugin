//
// Feature.swift
//

import Components
import DependencyContainer
import DesignSystem
import Routes
import SharedModel
import ToolKit
import UIKit

public protocol FeatureContainer: DependencyContainer where DependencyKey == ObjectIdentifier {
    func routeContainer() async -> Router.Container
}

public actor Feature<Container: FeatureContainer>: ToolKit.Feature {
    public var services: [any ToolKit.Service] = []
    public let container: ObjectContainer
    public init(_ container: Container) async {
        self.container = await container.container

        await registerRepositories()
        await registerUseCases()

        // environment = resolve(FeatureEnvironment.self) ?? FeatureEnvironmentMock()

        await register(for: SceneViewModelFactory.self, scope: .singleton) {
            SceneViewModelFactory(self.container)
        }

        await register(for: ComponentViewModelFactory.self, scope: .singleton) {
            ComponentViewModelFactory(self.container)
        }

        await registerRoutes(routeContainer: unsafeResolve(),
                       viewModels: unsafeResolve())
    }
}
