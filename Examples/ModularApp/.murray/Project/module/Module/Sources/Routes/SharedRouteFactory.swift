{{ fileHeader }}

import ToolKit
import Routes
import Foundation
import Combine
import UIKit

public protocol SharedRouteFactory: PageRouteFactory {
    func root() -> Route
}
