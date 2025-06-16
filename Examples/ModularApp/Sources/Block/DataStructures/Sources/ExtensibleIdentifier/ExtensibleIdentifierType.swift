//
//  ExtensibleIdentifier.swift
//  CodableKit
//
//  Created by Stefano Mondino on 11/09/24.
//

import Foundation

public protocol ExtensibleIdentifierType: Hashable, Sendable, Codable, RawRepresentable {
    associatedtype Value: Hashable & Sendable & Codable
    var value: Value { get }
    init(_ value: Value)
}

public extension ExtensibleIdentifierType {
    /// Decodes an identifier from a decoder.
    /// - Parameter decoder: The decoder to read data from.
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Value.self)
        self.init(value)
    }
    /// Encodes the identifier to an encoder.
    /// - Parameter encoder: The encoder to write data to.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
extension ExtensibleIdentifierType where Value: CustomStringConvertible {
    /// A textual representation of the identifier.
    public var description: String { value.description }
}

extension ExtensibleIdentifierType where Value: CustomDebugStringConvertible {
    /// A debug textual representation of the identifier.
    public var debugDescription: String { value.debugDescription }
}

extension ExtensibleIdentifierType  {
    /// The raw value of the identifier.
    public var rawValue: Value { value }
    /// Creates an identifier from a raw value.
    public init?(rawValue: Value) {
        self.init(rawValue)
    }
}

/// A typealias for a string-based extensible identifier.
public typealias StringIdentifier<Tag> = ExtensibleIdentifier<String, Tag>
/// A typealias for an integer-based extensible identifier.
public typealias IntIdentifier<Tag> = ExtensibleIdentifier<Int, Tag>
/// A typealias for a boolean-based extensible identifier.
public typealias BoolIdentifier<Tag> = ExtensibleIdentifier<Bool, Tag>
/// A typealias for a float-based extensible identifier.
public typealias FloatIdentifier<Tag> = ExtensibleIdentifier<Float, Tag>

extension ExtensibleIdentifierType where Value == String {
    /// Creates an identifier from a string literal.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension ExtensibleIdentifierType where Value == IntegerLiteralType {
    /// Creates an identifier from an integer literal.
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension ExtensibleIdentifierType where Value == Bool {
    /// Creates an identifier from a boolean literal.
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension ExtensibleIdentifierType where Value == Float {
    /// Creates an identifier from a float literal.
    public init(floatLiteral value: Float) {
        self.init(value)
    }
}
/// Provides a syntax close to enum case to ExtensibleIdentifierType objects
///
///  - Warning:
///         Swift 6.0 does not support static property wrappers and strict concurrency at the same time.
///         This feature is mostly here for future reference, hoping that static property wrappers will somehow find their place in the strict concurrency world
///
///  Example:
///  ```swift
///  typealias MyIdentifier = ExtensibleIdentifier<String, MyObject>
///  extension MyIdentifier {
///    @Case("my_value") static var myValue
///  }
///
///   switch myIdentifier {
///     case .myValue: // do something
///     default: break
///   }
///  ```
///  Will create a new ExtensibleIdentifier wrapping a String and constrained to MyObject that matches `"my_value"` external value to a variable named `myValue
///
@propertyWrapper public struct ExtensibleIdentifierCase<Identifier: ExtensibleIdentifierType>: Sendable {
    let key: Identifier.Value
    /// Creates a new case with the given key.
    /// - Parameter key: The value for the case.
    public init(_ key: Identifier.Value) {
        self.key = key
    }
    /// The wrapped identifier value.
    public var wrappedValue: Identifier {
        return .init(key)
    }
}

