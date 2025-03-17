import ProjectDescription

public extension DeploymentTargets {
    var filters: PlatformFilters {
        var filter = PlatformFilters()
        if iOS != nil { filter.insert(.ios) }
        if watchOS != nil { filter.insert(.watchos) }
        if macOS != nil { filter.insert(.macos) }
        if tvOS != nil { filter.insert(.tvos) }
        if visionOS != nil { filter.insert(.visionos) }
        return filter
    }
}
