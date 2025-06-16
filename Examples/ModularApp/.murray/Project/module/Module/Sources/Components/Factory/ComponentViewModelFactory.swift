{{fileHeader}}

import ToolKit
import Components
import Foundation
import Combine
import DesignSystem

class ComponentViewModelFactory: WithSharedComponentViewModelFactory, Boomerang.SharedDependencyContainer {

    @Dependency var shared: SharedComponentViewModelFactory
    @Dependency var routes: RouteFactory

    init() {

    }

    // murray: implementation
}
