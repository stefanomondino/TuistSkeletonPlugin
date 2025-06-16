{{ fileHeader }}

import Combine
import ToolKit
import Components
import Routes
import Foundation
import UIKit

class RouteFactoryImplementation: RouteFactory, Boomerang.SharedDependencyContainer {
    @Dependency var lifecycle: LifecycleRouteFactory
    @Dependency var scenes: SceneFactory
    @Dependency var sceneViewModels: SceneViewModelFactory

    init() {}

    func page(from _: ViewModel) -> Route? {
        nil
    }

    func root() -> Route {
        EmptyRoute { [self] in
            nil
        }
    }
}
