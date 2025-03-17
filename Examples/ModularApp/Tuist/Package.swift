// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers
    
    let packageSettings = PackageSettings(
        productTypes: [
            "Kingfisher": .framework
        ])
#endif

let package = Package(
    name: "Project",
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.0.0")
    ])