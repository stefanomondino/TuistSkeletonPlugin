//
//  ResourceSynthesizer+Helpers.swift
//  ProjectDescriptionHelpers
//
//  Created by Stefano Mondino on 02/01/23.
//

import ProjectDescription

public extension ResourceSynthesizer {
    static var vocabulary: ResourceSynthesizer {
        .custom(name: "Vocabulary",
                parser: .json,
                extensions: ["vocabulary"])
    }

    static var environment: ResourceSynthesizer {
        .custom(name: "Environment",
                parser: .json,
                extensions: ["environment"])
    }
}
