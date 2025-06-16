{{ fileHeader }}

import ToolKit
import Foundation
import Networking
import XCTest

@testable import {{ name | firstUppercase }}

class {{ name | firstUppercase }}Tests: XCTestCase {

    func testEmpty() {
        XCAssert(true)
    }
}
