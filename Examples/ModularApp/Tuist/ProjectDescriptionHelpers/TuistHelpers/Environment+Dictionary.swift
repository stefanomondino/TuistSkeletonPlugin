//
//  Environment+Dictionary.swift
//  ProjectDescriptionHelpers
//
//  Created by Stefano Mondino on 05/01/23.
//

import Foundation
import ProjectDescription

public indirect enum DictionaryValue: Codable, Equatable {
    /// It represents a string value.
    case string(String)

    /// It represents an integer value.
    case integer(Int)

    /// It represents a floating value.
    case real(Double)

    /// It represents a boolean value.
    case boolean(Bool)

    /// It represents a dictionary value.
    case dictionary([String: DictionaryValue])

    /// It represents an array value.
    case array([DictionaryValue])

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .array(values): try container.encode(values)
        case let .boolean(value): try container.encode(value)
        case let .string(value): try container.encode(value)
        case let .integer(value): try container.encode(value)
        case let .real(value): try container.encode(value)
        case let .dictionary(value): try container.encode(value)
        }
    }

    public var plistValue: ProjectDescription.Plist.Value {
        switch self {
        case let .array(values): .array(values.map { $0.plistValue })
        case let .boolean(value): .boolean(value)
        case let .string(value): .string(value)
        case let .integer(value): .integer(value)
        case let .real(value): .real(value)
        case let .dictionary(value): .dictionary(value.reduce(into: [:]) {
                $0[$1.key] = $1.value.plistValue
            })
        }
    }

    public var settingValue: SettingValue? {
        switch self {
        case let .array(values): .array(values.compactMap { switch $0.settingValue {
            case let .string(value): value
            default: nil
            } })
        case let .boolean(value): .init(booleanLiteral: value)
        case let .string(value): .init(stringLiteral: value)
        case let .integer(value): .init(stringLiteral: "\(value)")
        case let .real(value): .init(stringLiteral: "\(value)")
        case .dictionary: nil
        }
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .integer(int)
        } else if let real = try? container.decode(Double.self) {
            self = .real(real)
        } else if let boolean = try? container.decode(Bool.self) {
            self = .boolean(boolean)
        } else if let dictionary = try? container.decode([String: DictionaryValue].self) {
            self = .dictionary(dictionary)
        } else if let array = try? container.decode([DictionaryValue].self) {
            self = .array(array)
        } else {
            fatalError()
        }
    }
}

// MARK: - InfoPlist.Value - ExpressibleByStringInterpolation

extension DictionaryValue: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

// MARK: - InfoPlist.Value - ExpressibleByIntegerLiteral

extension DictionaryValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .integer(value)
    }
}

// MARK: - InfoPlist.Value - ExpressibleByFloatLiteral

extension DictionaryValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .real(value)
    }
}

// MARK: - InfoPlist.Value - ExpressibleByBooleanLiteral

extension DictionaryValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}

// MARK: - InfoPlist.Value - ExpressibleByDictionaryLiteral

extension DictionaryValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, DictionaryValue)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}

// MARK: - InfoPlist.Value - ExpressibleByArrayLiteral

extension DictionaryValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: DictionaryValue...) {
        self = .array(elements)
    }
}

public extension [String: DictionaryValue] {
    var plistValue: [String: Plist.Value] {
        reduce(into: [:]) { $0[$1.key] = $1.value.plistValue }
    }

    var settingValue: [String: SettingValue] {
        reduce(into: [:]) { $0[$1.key] = $1.value.settingValue }
    }
}
