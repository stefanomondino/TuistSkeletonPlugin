//
//  TypographyProvider.swift
//  DesignSystem
//
//  Created by Stefano Mondino on 10/06/25.
//

import Foundation
import DependencyContainer
import DataStructures

extension Typography {
    
    public struct Key: ExtensibleIdentifierType, ExpressibleByStringInterpolation {
        public let value: String
        public init(_ value: String) {
            self.value = value
        }
    }
    
    @dynamicMemberLookup
    @MainActor public final class Provider: MainActorProvider {
        
        public var provider: [Typography.Key : () -> Any] = [:]
        public typealias Key = Typography.Key
        let defaultValue: Typography
        
        public init(defaultValue: Typography = Typography()) {
            self.defaultValue = defaultValue
        }
        
        public subscript(dynamicMember key: Key) -> Typography {
            resolve(key, default: defaultValue)
        }
    }
    
}
