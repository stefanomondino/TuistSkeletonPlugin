{{ fileHeader }}

import Components
import ToolKit
@testable import {{ name | firstUppercase }}

class ModuleTests: TestCase {
    func testDependencyContainerProperlyInitialized() {
        let container = Module()
        XCTAssertNotNil(container.resolve(RouteFactory.self))
        XCTAssertNotNil(container.resolve(SharedRouteFactory.self))
        XCTAssertNotNil(container.resolve(SceneViewModelFactory.self))
        XCTAssertNotNil(container.resolve(SceneFactory.self))
        XCTAssertNotNil(container.resolve(ComponentFactory.self))
    }
}
