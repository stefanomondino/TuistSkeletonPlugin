//
//  BlockModules.swift
//  Manifests
//
//  Created by Stefano Mondino on 04/06/25.
//
import SkeletonPlugin
import ProjectDescription

public extension Skeleton.BlockModule {
    static func logger() -> Self {
        .init(name: "Logger", destinations: Constants.destinations,
                            deploymentTargets: .custom,
                            swiftVersion: .v6,
                            testDependencies: .init(test: [.coreTesting()]),
                            synthesizers: [])
    }

    static func dependencyContainer() -> Self {
        .init(name: "DependencyContainer",
                            destinations: Constants.destinations,
                            deploymentTargets: .custom,
                            swiftVersion: .v6,
                            testDependencies: .init(test: [.coreTesting()]),
                            synthesizers: [])
    }

    static func streams() -> Self {
        .init(name: "Streams",
                            destinations: Constants.destinations,
                            deploymentTargets: .custom,
                            swiftVersion: .v6,
                            dependencies: .init(external: [.asyncAlgorithms()]),
                            testDependencies: .init(test: [.coreTesting()]),
                            synthesizers: [])
    }
    static func dataStructures() -> Self {
        .init(name: "DataStructures",
                            destinations: Constants.destinations,
                            deploymentTargets: .custom,
                            swiftVersion: .v6,
                            dependencies: .init(external: []),
                            testDependencies: .init(test: [.coreTesting()]),
                            synthesizers: [],
                            hasMacros: true)
    }
}
