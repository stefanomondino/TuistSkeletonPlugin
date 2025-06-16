//
//  BaseProtocol.swift
//  DependencyContainer
//
//  Created by Stefano Mondino on 09/06/25.
//


//
//  DependencyContainerTests.swift
//
//
//  Created by Stefano Mondino on 05/12/21.
//

@testable import DependencyContainer
import Foundation
import Testing

protocol BaseProtocol {}
protocol ExtendedProtocol: BaseProtocol {}

final class DependencyContainerTests {
    enum Key: String, Hashable, Sendable {
        case dependencyA
        case dependencyB
    }

    final class TestObject: CustomStringConvertible, Equatable, ExtendedProtocol, Sendable {
        static func == (lhs: DependencyContainerTests.TestObject, rhs: DependencyContainerTests.TestObject) -> Bool {
            lhs.content == rhs.content
        }

        var description: String { content.description }
        let content: UUID = .init()
        init() {}
    }

    struct TestStruct: CustomStringConvertible, Equatable {
        static func == (lhs: DependencyContainerTests.TestStruct, rhs: DependencyContainerTests.TestStruct) -> Bool {
            lhs.content == rhs.content
        }

        var description: String { content.description }
        let content: UUID = .init()
        init() {}
    }

    actor TestContainer<Key: Hashable & Sendable>: DependencyContainer {
        let container: Container<Key>
        init(_ container: Container<Key>) {
            self.container = container
        }
    }

    actor CustomContainer: DependencyContainer {
        let container = ObjectContainer()
        init() {}

//        func testObject() async -> CustomStringConvertible {
//            await unsafeResolve(CustomStringConvertible.self)
//        }
    }

    @Test
    func object_container_resolves_types_via_object_identifier() async throws {
        let container = TestContainer(ObjectContainer())
        await container.register {
            "test"
        }
        await container.register(for: Int.self) {
            1
        }
        #expect(await container.resolve(String.self) == "test")
        #expect(await container.resolve(Int.self) == 1)
    }

    @Test
    func object_container_resolves_via_keys() async throws {
        let container = TestContainer(Container<Key>())
        await container.register(for: .dependencyA) {
            "test"
        }
        #expect(await container.resolve(.dependencyA, type: String.self) == "test")
    }

    @Test
    func object_container_with_unique_scope_returns_different_values() async throws {
        let container = TestContainer(Container<Key>())

        await container.register(for: .dependencyA) {
            TestObject()
        }
        let valueA: TestObject = await container.unsafeResolve(.dependencyA)
        let valueB: TestObject = await container.unsafeResolve(.dependencyA)
        #expect(valueA.content != valueB.content)
    }
    /*
        func testSingletonScopeReturningSameInstances() throws {
            let container = TestContainer(Container<Key>())

            container.register(for: .dependencyA, scope: .singleton) {
                TestObject()
            }
            let valueA: TestObject = container[.dependencyA]
            let valueB: TestObject = container[.dependencyA]
            XCTAssertEqual(valueA.content, valueB.content)
        }

        func testEagerSingletonScopeReturningSameInstancesAndImmediatelyInstantiate() throws {
            let container = TestContainer(Container<Key>())
            var initialized = false
            container.register(for: .dependencyA, scope: .eagerSingleton) { () -> TestObject in
                initialized = true
                return TestObject()
            }
            XCTAssertTrue(initialized)
            let valueA: TestObject = container[.dependencyA]
            let valueB: TestObject = container[.dependencyA]
            XCTAssertEqual(valueA.content, valueB.content)
        }

        func testSingletonScopeReturningDifferentInstancesOnOverride() throws {
            let container = TestContainer(Container<Key>())

            container.register(for: .dependencyA, scope: .singleton) {
                TestObject()
            }
            let valueA: TestObject = container[.dependencyA]
            container.register(for: .dependencyA, scope: .singleton) {
                TestObject()
            }
            let valueB: TestObject = container[.dependencyA]
            XCTAssertNotEqual(valueA.content, valueB.content)
        }

        func testWeakDependencyOnAnyObject() throws {
            let container = ObjectContainer()
            container.register(for: TestObject.self, scope: .weakSingleton) { TestObject() }
            var object = container.resolve(TestObject.self)
            let previousObjectContent = object?.content
            XCTAssertNotNil(object)
            XCTAssertNotNil(container.resolve(TestObject.self))
            XCTAssertEqual(object, container.resolve(TestObject.self))
            object = nil
            let resolvedAgain = try XCTUnwrap(container.resolve(TestObject.self))
            XCTAssertNotEqual(resolvedAgain.content, previousObjectContent)

            container.register(for: String.self, scope: .weakSingleton) { "TEST" }
            XCTAssertEqual(container.resolve(), "TEST")
            container.register(for: Int.self, scope: .weakSingleton) { 1 }
            XCTAssertEqual(container.resolve(), 1)
        }

        func testWeakDependencyOnStructs() throws {
            let container = ObjectContainer()
            container.register(scope: .weakSingleton) { TestStruct() }
            var object = container.resolve(TestStruct.self)
            let previousObjectContent = object?.content
            XCTAssertNotNil(object)
            XCTAssertNotNil(container.resolve(TestStruct.self))
            /// Since there's no concept of "weak" on structs, every resolution will always return a different value as in `unique` scope
            XCTAssertNotEqual(object, container.resolve(TestStruct.self))
            object = nil
            let resolvedAgain = try XCTUnwrap(container.resolve(TestStruct.self))
            XCTAssertNotEqual(resolvedAgain.content, previousObjectContent)

            container.register(scope: .weakSingleton) { "TEST" }
            XCTAssertEqual(container.resolve(), "TEST")
            container.register(scope: .weakSingleton) { 1 }
            XCTAssertEqual(container.resolve(), 1)
        }

        func testExtensionRegistration() throws {
            let baseObject = TestObject()
            let container = ObjectContainer()
            container.register(for: ExtendedProtocol.self) { baseObject }
            container.register(for: BaseProtocol.self) { container.unsafeResolve(ExtendedProtocol.self) }
            let resolved = try XCTUnwrap(container.resolve(ExtendedProtocol.self))
            XCTAssertEqual(baseObject, resolved as? TestObject)
        }

        func testNonSharedContainerResolvesDifferentVariables() throws {
            class Container: DependencyContainer {
                let container = ObjectContainer()
            }

            let containerA = Container()
            let containerB = Container()

            containerA.register { "This is a test" }
            XCTAssertNotEqual(containerB.resolve(), "This is a test")
        }

        func testStandaloneContainer() throws {
            let container = ObjectContainer()
            container.register(for: String.self) { "TEST" }
            XCTAssertEqual(container.resolve(), "TEST")
        }
     */
}

protocol MyContainer {
    func register<Value>(_ block: @escaping () -> Value)
    func resolve<Value>(_ type: Value.Type) throws -> Value
}

extension MyContainer {}
