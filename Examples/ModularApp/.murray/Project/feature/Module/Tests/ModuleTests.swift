//
// ModuleTests.swift
//

import DependencyContainer
import FeatureTesting
import Routes
@testable import {{ name | firstUppercase }}

typealias TestFeature = {{ name | firstUppercase }}.Feature<TestContainer>

class TestCase: FeatureTesting.TestCase<TestFeature> {
    override func setUp() async throws {
        try await super.setUp()
        let testContainer = await TestContainer(container.container)
        await container.register { testContainer }
        await container.register(scope: .eagerSingleton) { await Feature(testContainer) }
    }
}

actor TestContainer: FeatureContainer {
    let container: ObjectContainer
    func routeContainer() async -> Routes.Router.Container {
        await unsafeResolve()
    }

    init(_ container: ObjectContainer) async {
        self.container = container
        await register(for: Router.Container.self, scope: .singleton) { .init() }
    }
}
