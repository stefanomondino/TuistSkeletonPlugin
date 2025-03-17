//
//  ProjectDefinition.swift
//  ProjectDescriptionHelpers
//
//  Created by Stefano Mondino on 09/02/23.
//

import Foundation
import ProjectDescription

public enum ProjectDefinition {
    public struct Product {
        public var product: ProjectDescription.Product
        public static var automaticFramework: Self {
            if ProjectDescription.Environment.forceStaticLibraries != nil {
                return .init(.staticLibrary)
            }
            return .init(.framework)
        }

        public init(_ product: ProjectDescription.Product) {
            self.product = product
        }
    }
}
