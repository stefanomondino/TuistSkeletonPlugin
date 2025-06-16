{{ fileHeader }}

import Combine
import Foundation
import Logger
import Networking
import {{ name | firstUppercase }}Client

public protocol {{ name | firstUppercase }}Repository {
    
}

class {{ name | firstUppercase }}RepositoryImplementation {
    // var {{ name | firstLowercase }}: {{ name | firstUppercase }}Client.Client { get }
    init() {}
}

