import ProjectDescription
import SkeletonPlugin

public extension Skeleton {
    enum ModularApp {
        public struct AppConstants: Codable, Equatable, Sendable {
            public let baseURL: String
        }

        public struct Dependencies: ModuleDependencies {
            public var isPrivate: Bool { true }
            public var core: [CoreModule]
            public var bridge: [BridgeModule]
            public var feature: [FeatureModule]
            public var external: [ExternalModule]
            public var dependencies: [DependencyBuilder] { core + bridge + feature }
            public init(core: [CoreModule] = [], bridge: [BridgeModule] = [], feature: [FeatureModule] = [], external: [ExternalModule] = []) {
                self.core = core
                self.bridge = bridge
                self.feature = feature
                self.external = external
            }
        }

        // swiftlint:disable function_body_length
        public static func app() -> Skeleton.PhoneAppModule<AppConstants> {
            Skeleton.PhoneAppModule(name: "ModularApp",
                                    folder: "ModularApp",
                                    destinations: Constants.iOSDestinations,
                                    swiftVersion: .v6,
                                    iOSVersion: Constants.iOSDeploymentTarget,
                                    appVersion: ProjectDescription.Environment.versionName.getString(default: "1.0.0"),
                                    environments: [.init(name: "Dev",
                                                         productName: "ModularAppDev",
                                                         fastlane: .init(applyBadge: true,
                                                                         distributionGroups: [""],
                                                                         destination: .appstore,
                                                                         appleIdentifier: "",
                                                                         teamName: Constants.defaultAppstoreConnectTeamName,
                                                                         exportType: .appstore),
                                                         bundleIdentifier: "com.stefanomondino.modularapp.dev",
                                                         constants: AppConstants(baseURL: "https://stefanomondino.com/dev"),
                                                         iOSDeploymentTarget: Constants.iOSDeploymentTarget,
                                                         teamID: Constants.defaultTeamID,
                                                         displayName: "MA DEV",
                                                         entitlements: ["com.apple.developer.associated-domains": ["applinks:stefanomondino.com"],
                                                                        "aps-environment": "development"],
                                                         plist: ["NSCameraUsageDescription": "camera_usage_description",
                                                                 "NSBluetoothAlwaysUsageDescription": "bluetooth_description",
                                                                 "NSMicrophoneUsageDescription": "microphone_description",
                                                                 "NSUserTrackingUsageDescription": "att_description",
                                                                 "NSLocationWhenInUseUsageDescription": "location_in_use_description",
                                                                 "NSLocationAlwaysAndWhenInUseUsageDescription": "location_always_description",
                                                                 "UILaunchStoryboardName": "LaunchScreen",
                                                                 "UIRequiredDeviceCapabilities": ["armv7"],
                                                                 "UIStatusBarHidden": false,
                                                                 "UIRequiresFullScreen": true,
                                                                 "UIStatusBarStyle": "UIStatusBarStyleLightContent",
                                                                 "UIUserInterfaceStyle": "Light",
                                                                 "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait", "UIInterfaceOrientationLandscapeLeft", "UIInterfaceOrientationLandscapeRight"],
                                                                 "LSRequiresIPhoneOS": true,
                                                                 "UIBackgroundModes": ["audio", "fetch", "remote-notification"],
                                                                 "FirebaseAutomaticScreenReportingEnabled": false,
                                                                 "UIApplicationSupportsIndirectInputEvents": true,
                                                                 "ITSAppUsesNonExemptEncryption": false,
                                                                 "LSApplicationQueriesSchemes": [],
                                                                 "CFBundleURLTypes": [
                                                                     ["CFBundleURLName": "modularappdev",
                                                                      "CFBundleURLSchemes": .array([.string("modularappdev")])]
                                                                 ]],
                                                         isTestable: true)],
                                    organizationName: "Stefano Mondino",
                                    dependencies: Dependencies(bridge: [],
                                                               feature: [.onboarding()],
                                                               external: []),
                                    supplementarySources: [],
                                    supplementaryResources: [],
                                    customScripts: [],
                                    extensions: { _ in
                                        []
                                    })
        }
    }
}
