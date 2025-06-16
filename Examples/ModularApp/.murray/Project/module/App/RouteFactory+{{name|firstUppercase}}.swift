{{ fileHeader }}

import ToolKit
import Foundation
#if canImport({{name|firstUppercase}})
    import {{name|firstUppercase}}

    extension RouteFactoryImplementation {
        private var {{name|firstLowercase}}: {{name|firstUppercase}}.Module { unsafeResolve() }

//        func root() -> Route {
//            {{name|firstLowercase}}.routes.root()
//        }
    }

#else
    extension RouteFactoryImplementation {
//        func root() -> Route { EmptyRoute() }
    }
#endif
