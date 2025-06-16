{{ fileHeader }}

import Foundation
import Networking

public struct Config {
    var baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
