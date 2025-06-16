{{ fileHeader }}

import ToolKit
import Foundation

var environment: {{ name | firstUppercase }}.Environment = EnvironmentMock()

// sourcery: AutoMockable
public protocol Environment: Core.Environment {}
