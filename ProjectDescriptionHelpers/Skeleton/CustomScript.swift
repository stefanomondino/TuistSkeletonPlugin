//
//  CustomScript.swift
//  ProjectDescriptionHelpers
//
//  Created by Andrea Altea on 22/01/24.
//

import ProjectDescription

public extension Skeleton {
    enum CustomScript: Sendable {
        case none
        case script(ScriptConvertible)

        public init(from _: Decoder) throws {
            self = .none
        }

        public func encode(to _: Encoder) throws {}

        func targetScript<Module: AppModule>(for app: Module, environment: Module.Environment) -> TargetScript? {
            switch self {
            case let .script(convertible): convertible.targetScript(for: app, environment: environment)
            default: nil
            }
        }
    }
}

public protocol ScriptConvertible: Sendable {
    func targetScript<Module: AppModule>(for app: Module, environment: Module.Environment) -> TargetScript?
}
