{{ fileHeader }}

import Components
import Foundation

protocol ComponentFactory: Components.ComponentFactory {}

class ComponentFactoryImplementation: Components.ComponentFactoryImplementation, ComponentFactory {
    init() {
        super.init(bundle: .module)
    }
}
