//
//  ExtensibleIdentifier.swift
//  CodableKitten
//
//  Created by Stefano Mondino on 19/05/25.
//

/// A generic, type-safe identifier that can be extended with a tag type.
/// Useful for creating distinct identifier types from the same underlying value type while retaining type safety and extensibility, compared to enums.
public struct ExtensibleIdentifier<Value: Hashable & Sendable & Codable, Tag>: ExtensibleIdentifierType {
    
    /// The underlying value of the identifier.
    public var value: Value
    
    /// Creates a new identifier with the given value.
    /// - Parameter value: The value to wrap.
    public init(_ value: Value) {
        self.value = value
    }

    /// Hashes the essential components of the identifier.
    /// - Parameter hasher: The hasher to use.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(ObjectIdentifier(Tag.self))
    }
    
    /// Compares two identifiers for equality.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

extension ExtensibleIdentifier {
    public typealias Case = ExtensibleIdentifierCase<Self>
}

extension ExtensibleIdentifier: ExpressibleByStringLiteral where Value == String {}
extension ExtensibleIdentifier: ExpressibleByExtendedGraphemeClusterLiteral where Value == String {}
extension ExtensibleIdentifier: ExpressibleByUnicodeScalarLiteral where Value == String {}
extension ExtensibleIdentifier: ExpressibleByStringInterpolation where Value == String {}
extension ExtensibleIdentifier: ExpressibleByFloatLiteral where Value == Float {}
extension ExtensibleIdentifier: ExpressibleByBooleanLiteral where Value == Bool {}
extension ExtensibleIdentifier: ExpressibleByIntegerLiteral where Value == IntegerLiteralType {}


