{{ fileHeader }}

@testable import {{ name | firstUppercase }}
import ToolKit
import Components
import Routes
import Foundation
import TestUtilities
import XCTest

class RouteFactoryTests: TestCase {
    lazy var scenes: SceneFactory = .init(components: ComponentFactoryImplementation())

    private let module = Module()
    lazy var factory: RouteFactory = container.unsafeResolve()

    private func exploreCallback(_ scene: Scene) -> Scene? {
        switch scene {
        case let navigationController as UINavigationController:
            return navigationController.topViewController
        case let tab as UITabBarController:
            return tab.selectedViewController
        case let navigationContainer as NavigationContainer:
            return navigationContainer.rootViewController
        default: return nil
        }
    }

    func testMainRootPage() {
        let route = factory.root()
        assert(route, of: EmptyRoute.self)
        assert(route,
               hierarchy: [],
               exploring: exploreCallback(_:))
    }
}
