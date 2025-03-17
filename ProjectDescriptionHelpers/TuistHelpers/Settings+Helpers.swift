//
//  Settings+Helpers.swift
//  ProjectDescriptionHelpers
//
//  Created by Stefano Mondino on 24/11/22.
//

import ProjectDescription

extension ConfigurationName: ExpressibleByStringInterpolation {}

// public extension App.Environment {
////    public var name: String {
////        rawValue.capitalized
////    }
////
//    var configurations: [Configuration] {
//        [.debug(name: "Debug",
//                settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) \(name.uppercased())"]),
//         .release(name: "Release",
//                  settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) \(name.uppercased())"])]
//    }
// }
