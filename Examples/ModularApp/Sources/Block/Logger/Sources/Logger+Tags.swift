//
//  Logger+Tags.swift
//  Core
//
//  Created by Stefano Mondino on 15/11/20.
//

import Foundation

public extension Logger {
    enum Tag: CustomStringConvertible, Equatable, ExpressibleByStringInterpolation, Sendable {
        case none
        case lifecycle
        case api
        case tracking
        case routes
        case custom(String)
        public init(stringLiteral value: String) {
            self = .custom(value)
        }

        public var description: String {
            switch self {
            case .none: ""
            case .lifecycle: "LIFECYCLE"
            case .api: "API"
            case .tracking: "TRACKING"
            case .routes: "ROUTES"
            case let .custom(string): string.uppercased()
            }
        }
    }
}
