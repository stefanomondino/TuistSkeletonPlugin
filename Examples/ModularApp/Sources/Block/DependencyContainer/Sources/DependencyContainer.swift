//
//  DependencyContainer.swift
//  DependencyContainer
//
//  Created by Stefano Mondino on 09/06/25.
//

import Foundation

/**
 Defines the ability of storing and lately resolving dependencies identified by a single key
 */
public protocol DependencyContainer: Sendable {
    /// The container's key type. Must be `Hashable`.
    associatedtype DependencyKey: Hashable, Sendable
    /// A container object
    var container: Container<DependencyKey> { get async }
}

public struct ContainerTag: Hashable, ExpressibleByStringInterpolation, Sendable {
    let tag: String
    public static var empty: ContainerTag { .init("") }
    public init(_ tag: CustomStringConvertible) {
        self.tag = tag.description
    }

    public init(stringLiteral value: String) {
        tag = value
    }
}

/**
 An object capable of storing dependencies and lately retrieve them according to unique keys

 Usually it simply needs to be instantiated in a `DependencyContainer` context,
 providing the key type (`DependencyKey` generic type)
 */
public actor Container<DependencyKey: Hashable>: DependencyContainer where DependencyKey: Sendable {
    struct Dependency: Sendable {
        let scope: Scope
        let closure: @Sendable () async -> Sendable
    }

    /**
        The scope of a dependency

        Dependencies are closures generating objects.

        When a dependency is resolved by a dependency container, the default behavior is to re-execute the dependency closure, thus generating a new resulting object.
        In some cases, the resulting object must be stored and retrieved lately, without being generating twice (like in the singleton pattern).
        `Scope` helps deciding which behavior must be adopted.
     */
    public enum Scope: Sendable {
        /// Dependency closure is executed for each resolution. Resulting object is always a new instance
        case unique
        /// Dependency closure is executed only at first resolution. Resulting object is cached and returned for each subsequent call, instead of re-executing the closure.
        case singleton
        /// Dependency closure is executed immediately upon registration. Resulting object is cached and returned for each subsequent call, instead of re-executing the closure.
        case eagerSingleton
        /** Dependency closure is executed only at first resolution.
         Resulting object is cached weakly and returned for each subsequent call, as long as previous value has ben strongly referenced somewhere else.
         On structs types, this has no effect and has no differences with `unique` scope.
         */
        case weakSingleton
    }

    private class WeakWrapper {
        weak var value: AnyObject?
        init(value: AnyObject) {
            self.value = value
        }
    }

    struct InternalKey: Hashable {
        let key: DependencyKey
        let tag: ContainerTag
    }

    public var container: Container<DependencyKey> { self }

    private var dependencies: [InternalKey: Dependency] = [:]
    private var singletons: [InternalKey: Any] = [:]
    private var weakSingletons: [InternalKey: WeakWrapper] = [:]

    public init() {}

    func register(for key: DependencyKey,
                  tag: ContainerTag = .empty,
                  scope: Container<DependencyKey>.Scope = .unique,
                  handler: @Sendable @escaping () async -> some Any) async {
        let internalKey = Container.InternalKey(key: key, tag: tag)
        singletons[internalKey] = nil
        dependencies[internalKey] = Container<DependencyKey>.Dependency(scope: scope,
                                                                        closure: handler)
    }

    func resolve<Value: Sendable>(_ key: DependencyKey, tag: ContainerTag = .empty) async -> Value? {
        let internalKey = Container.InternalKey(key: key, tag: tag)
        guard let dependency = dependencies[internalKey] else { return nil }
        switch dependency.scope {
        case .unique:
            return await dependency.closure() as? Value
        case .weakSingleton:
            guard let value = weakSingletons[internalKey]?.value else {
                let newValue = await dependency.closure() as AnyObject
                weakSingletons[internalKey] = .init(value: newValue)
                return newValue as? Value
            }
            return value as? Value
        case .singleton, .eagerSingleton:
            guard let value = singletons[internalKey] else {
                let newValue = await dependency.closure()
                singletons[internalKey] = newValue
                return newValue as? Value
            }
            return value as? Value
        }
    }
}

public extension DependencyContainer {
    /**
        Register a new dependency in the container for given key and scope.

        A dependency is simply a closure producing some kind of value.

         Register a dependency on an already used key **overwrites** previous closure value. If a `.singleton` or `.eagerSingleton` scope was used, the cached value is cleared.

        Examples:

        - `dependencyContainer.register(for: "firstName", scope: .unique) { "John Doe" }`

        - `dependencyContainer.register(for: "birthdate", scope: .singleton) { Date() }`

        - Parameter key: the unique key that will be used inside the container to identify the dependency.

        - Parameter scope: the scope of the dependency. Defaults to `Container.Scope.unique`

        - Parameter handler: the dependency that will be *resolved* lately, eventually producing a `Value` result.

     */
    func register<Value: Sendable>(for key: DependencyKey,
                                   tag: ContainerTag = .empty,
                                   scope: Container<DependencyKey>.Scope = .unique,
                                   handler: @Sendable @escaping () async -> Value) async {
        await container.register(for: key, tag: tag, scope: scope, handler: handler)
        switch scope {
        case .eagerSingleton: _ = await resolve(key, type: Value.self, tag: tag) as Value?
        default: break
        }
    }

    /**
        Resolves a dependency against provided key

        Resolving a dependency generally means to execute previously registered closure in order to generate some `Value` object.

        If previous closure was registered with a `eagerSingleton` scope, the closure will not be executed and cached value will be immediately returned.

        If previous closure was registered with a `singleton` scope, the closure will only be executed once.

        If provided key was never registered, `nil` is immediately returned

        - Parameter key: the key to resolve.

        - Returns: a value resulting from dependency resolution.
     */
    func resolve<Value: Sendable>(_ key: DependencyKey, type _: Value.Type, tag: ContainerTag = .empty) async -> Value? {
        await container.resolve(key, tag: tag)
    }

    /**
     Returns unwrapped dependency for provided key

      - Warning: if key is not registered, a `fatalError` is thrown.
     */
    func unsafeResolve<Value: Sendable>(_ key: DependencyKey, type: Value.Type = Value.self) async -> Value {
        guard let element: Value = await resolve(key, type: type) else {
            fatalError("No dependency found for \(key)")
        }
        return element
    }
}

public typealias ObjectContainer = Container<ObjectIdentifier>

public extension DependencyContainer where DependencyKey == ObjectIdentifier {
    func register<Value: Sendable>(for key: Value.Type = Value.self,
                                   tag: ContainerTag = .empty,
                                   scope: Container<DependencyKey>.Scope = .unique,
                                   handler: @Sendable @escaping () async -> Value) async {
        await register(for: ObjectIdentifier(key), tag: tag, scope: scope, handler: handler)
    }

    /// Returns resolved dependency or nil if not found
    func resolve<Value: Sendable>(_ key: Value.Type = Value.self, type: Value.Type = Value.self, tag: ContainerTag = .empty) async -> Value? {
        await resolve(ObjectIdentifier(key), type: type, tag: tag)
    }

    func register<Value: Sendable>(for keyPath: KeyPath<Self, Value>,
                                   tag: ContainerTag = .empty,
                                   scope: Container<DependencyKey>.Scope = .unique,
                                   handler: @Sendable @escaping () async -> Value) async {
        await register(for: ObjectIdentifier(keyPath), tag: tag, scope: scope, handler: handler)
    }

    func resolve<Value: Sendable>(_ keyPath: KeyPath<Self, Value>, type: Value.Type = Value.self, tag: ContainerTag = .empty) async -> Value? {
        await resolve(ObjectIdentifier(keyPath), type: type, tag: tag)
    }

    /**
     Returns unwrapped dependency for provided key

      - Warning: if key is not registered, a `fatalError` is thrown.
     */
    func unsafeResolve<Value: Sendable>(_ key: Value.Type = Value.self, tag: ContainerTag = .empty) async -> Value {
        guard let value = await resolve(key, tag: tag) else {
            fatalError("No dependency found for \(key)")
        }
        return value
    }

    func unsafeResolve<Value: Sendable>(_ keyPath: KeyPath<Self, Value>, tag: ContainerTag = .empty) async -> Value {
        guard let value = await resolve(keyPath, tag: tag) else {
            fatalError("No dependency found for \(keyPath)")
        }
        return value
    }
}
