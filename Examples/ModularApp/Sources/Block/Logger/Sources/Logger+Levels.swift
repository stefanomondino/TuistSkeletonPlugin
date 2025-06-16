//
//  Logger+Levels.swift
//  Core
//
//  Created by Stefano Mondino on 15/11/20.
//

import Foundation

public extension Logger {
    enum Level: Int, Comparable, Sendable {
        public static func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        case useless = 0
        case verbose = 1
        case warning = 10
        case debug = 50
        case error = 100
        case none = 1000
    }
}
