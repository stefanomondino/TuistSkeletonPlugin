//
//  Fastlane.swift
//  ProjectDescriptionHelpers
//
//  Created by Stefano Mondino on 06/01/23.
//

import Foundation

public struct Fastlane: Codable, Equatable, Sendable {
    public enum ExportType: String, Sendable {
        case enterprise
        case adhoc
        case appstore

        var export: String {
            switch self {
            case .enterprise: "enterprise"
            case .adhoc: "ad-hoc"
            case .appstore: "app-store"
            }
        }

        var match: String {
            switch self {
            case .enterprise: "enterprise"
            case .adhoc: "adhoc"
            case .appstore: "appstore"
            }
        }
    }

    public enum DeployDestination: String, Codable, Sendable {
        case appstore
        case firebase
        case none
    }

    /// Apply a beta badge to app icon
    public let applyBadge: Bool
    /// The AppstoreConnect team name (warning: differs from Developer portal team ID used elsewhere).
    public let teamName: String?
    /// Firebase distribution groups to distribute the app to.
    public let distributionGroups: [String]
    public let destination: DeployDestination
    public let exportMethod: String
    public let matchType: String
    /// Apple id on the app information page on appstoreconnect - NOT an email Apple id, it's a number! Used to avoid 2FA
    public let appleIdentifier: String
    public init(applyBadge: Bool,
                distributionGroups: [String],
                destination: DeployDestination,
                appleIdentifier: String = "",
                teamName: String? = nil,
                exportType: ExportType) {
        self.applyBadge = applyBadge
        self.distributionGroups = distributionGroups
        self.destination = destination
        exportMethod = exportType.export
        matchType = exportType.match
        self.teamName = teamName
        self.appleIdentifier = appleIdentifier
    }
}
