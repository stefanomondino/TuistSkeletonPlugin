//
//  Typography.swift
//  DesignSystem
//
//  Created by Stefano Mondino on 10/06/25.
//
import DataStructures

public struct Typography: Sendable {
    public let temporaryValue: String
    public init(value: String = "Default") {
        self.temporaryValue = value
    }
    
}

public extension Typography.Key {
    static var test: Self { "test" }
}

