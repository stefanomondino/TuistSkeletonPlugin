{{ fileHeader }}

import ToolKit
import Foundation
import Networking
import XCTest

@testable import {{ name | firstUppercase }}Client

class ClientTests: XCTestCase {

    func testEmpty() {
        XCTAssert(true)
    }
}
