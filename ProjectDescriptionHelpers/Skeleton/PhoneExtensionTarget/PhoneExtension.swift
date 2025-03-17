import ProjectDescription

public protocol PhoneExtensionTarget: Encodable, Sendable {
    associatedtype AppConstants: Encodable, Equatable, Sendable
    var platforms: PlatformFilters { get }
    var bundleIdentifier: String { get }
    var environment: Skeleton.PhoneAppModule<AppConstants>.Environment { get }
    var name: String { get }
    func makeTarget(_ app: Skeleton.PhoneAppModule<AppConstants>) -> Target
    func dependency(appName: String) -> TargetDependency?
}

//
public extension Skeleton.PhoneAppModule {
    enum PhoneExtension: Encodable, Sendable {
        case notificationService(_ extension: NotificationService)
        case notificationContent(_ extension: NotificationContent)

        private var encodable: Encodable {
            switch self {
            case let .notificationContent(box): box
            case let .notificationService(box): box
            }
        }

        func target(_ app: Skeleton.PhoneAppModule<AppConstants>) -> Target {
            switch self {
            case let .notificationContent(box): box.makeTarget(app)
            case let .notificationService(box): box.makeTarget(app)
            }
        }

        func dependency(_ app: Skeleton.PhoneAppModule<AppConstants>) -> TargetDependency? {
            switch self {
            case let .notificationContent(box): box.dependency(appName: app.name)
            case let .notificationService(box): box.dependency(appName: app.name)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(encodable)
        }
    }
}
