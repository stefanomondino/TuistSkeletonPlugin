//
//  MainActorProvider.swift
//  DependencyContainer
//
//  Created by Stefano Mondino on 10/06/25.
//

public protocol MainActorProvider: AnyObject, Sendable {
    associatedtype Key: Hashable, Sendable
    @MainActor var provider: [Key: () -> Any] { get set }
}

public typealias MainActorTypeProvider = [ObjectIdentifier: () -> Any]

public extension MainActorProvider {
    
    @MainActor func register<Value: Sendable>(for key: Key, callback: @Sendable @escaping @MainActor () -> Value) {
        provider[key] = { callback() }
    }
    @MainActor func resolve<Value: Sendable>(_ key: Key, default defaultValue: Value) -> Value {
        guard let value = (provider[key]?() as? Value) else {
            register(for: key) { defaultValue }
            return defaultValue
        }
        return value
    }
    
    @MainActor func resolve<Value: Sendable>(_ key: Key) -> Value? {
        provider[key]?() as? Value
    }
}

public extension MainActorProvider where Key == ObjectIdentifier {
    @MainActor func register<Value: Sendable>(for key: Value.Type = Value.self, callback: @Sendable @escaping @MainActor () -> Value) {
        register(for: ObjectIdentifier(key), callback: callback)
    }
    
    @MainActor func resolve<Value: Sendable>(_ key: Value.Type = Value.self, default defaultValue: Value) -> Value {
        resolve(ObjectIdentifier(key), default: defaultValue)
    }
    @MainActor func resolve<Value: Sendable>(_ key: Value.Type = Value.self) -> Value? {
        resolve(ObjectIdentifier(key))
    }
}

@propertyWrapper @MainActor public struct Provided<Value: Sendable> {
    private let defaultValue: Value
    public init(defaultValue: Value) {
        self.defaultValue = defaultValue
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.defaultValue = nil
    }
    
    @available(*, unavailable,
       message: "This property wrapper can only be applied to classes")
    public var wrappedValue: Value {
            get { fatalError() }
            // swiftlint:disable unused_setter_value
            set { fatalError() }
        }
        
    public static subscript<Container: MainActorProvider>(
            _enclosingInstance instance: Container,
            wrapped wrappedKeyPath: ReferenceWritableKeyPath<Container, Value>,
            storage storageKeyPath: ReferenceWritableKeyPath<Container, Self>
        ) -> Value where Container.Key == ObjectIdentifier {
            get {
                if let value = instance.resolve(Value.self) {
                    return value
                }
                return instance[keyPath: storageKeyPath].defaultValue
            }
            set {}
        }
}
