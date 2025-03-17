import ProjectDescription

public extension Skeleton.PhoneAppModule {
    struct NotificationContent: PhoneExtensionTarget {
        enum CodingKeys: String, CodingKey {
            case extensionName
            case bundleIdentifier
            case name
            case category
        }

        public var extensionName: String
//        var extensionIdentifier: String
        public var name: String
        public var dependencies: ModuleDependencies
        public var entitlements: ProjectDescription.Entitlements?
        public var customScripts: [Skeleton.CustomScript] = []
        public var platforms: PlatformFilters { [.ios] }
        public var bundleIdentifier: String
        public var environment: Skeleton.PhoneAppModule<AppConstants>.Environment
        public var category: String
        public var deploymentTargets: DeploymentTargets { .iOS(environment.iOSDeploymentTarget) }
        public init(environment: Skeleton.PhoneAppModule<AppConstants>.Environment,
                    appName: String,
                    extensionName: String = "NotificationContent",
                    extensionIdentifier: String = "NotificationContent",
                    category: String = "CustomNotification",
                    dependencies: ModuleDependencies,
                    entitlements: ProjectDescription.Entitlements? = nil,
                    customScripts: [Skeleton.CustomScript] = []) {
            self.environment = environment
            self.extensionName = extensionName
            self.category = category
            self.dependencies = dependencies
            self.entitlements = entitlements
            self.customScripts = customScripts
            name = "\(appName)\(extensionName)\(environment.name)"
            bundleIdentifier = environment.bundleIdentifier + "." + extensionIdentifier
        }

        public func makeTarget(_ app: Skeleton.PhoneAppModule<AppConstants>) -> Target {
            .target(name: name,
                    destinations: app.destinations,
                    product: .appExtension,
                    bundleId: bundleIdentifier,
                    deploymentTargets: .iOS(environment.iOSDeploymentTarget),
                    infoPlist: .extendingDefault(with: ["CFBundleDisplayName": "\(extensionName)",
                                                        "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                                                        "NSExtension": [
                                                            "NSExtensionAttributes": [
                                                                "UNNotificationExtensionCategory": "\(category)",
                                                                "UNNotificationExtensionInitialContentSizeRatio": 1
                                                            ],
                                                            "NSExtensionPointIdentifier": "com.apple.usernotifications.content-extension",
                                                            "NSExtensionMainStoryboard": "MainInterface"
                                                        ]]),
                    sources: .sources(in: "Extensions/NotificationContent/Sources"),
                    resources: .resources(in: "Extensions/NotificationContent/Sources"),
                    dependencies: [.sdk(name: "UserNotifications", type: .framework),
                                   .sdk(name: "UserNotificationsUI", type: .framework)],
                    settings: .settings(base: environment.settings.settingValue,
                                        configurations: environment.configurations))
        }

        public func dependency(appName: String) -> TargetDependency? {
            .target(name: "\(appName)\(extensionName)\(environment.name)",
                    condition: .when(deploymentTargets.filters))
        }
    }
}
