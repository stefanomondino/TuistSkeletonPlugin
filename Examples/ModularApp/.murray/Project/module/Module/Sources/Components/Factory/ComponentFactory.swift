{{ fileHeader }}

import Components
import ToolKit
import Foundation

protocol ComponentFactory: Core.ComponentFactory {}

class ComponentFactoryImplementation: Components.ComponentFactoryImplementation, ComponentFactory {
    init() {
        super.init(bundle: .module)
    }
}
