// swift-tools-version: 6.2
import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers
    
    let packageSettings = PackageSettings(
        productTypes: [
            "Kingfisher": .framework
        ])
#endif

let macros: [PackageDescription.Package.Dependency] = [
    .package(path: "../Sources/Block/DataStructures/Macro"),
    .package(path: "../Sources/Core/DesignSystem/Macro"),
]

let package = Package(
    name: "Project",
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.0.0"),
        .package(url: "https://github.com/stefanomondino/swift-async-algorithms", branch: "main"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.0.0")
    ] + macros)
