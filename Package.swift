// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NStackSDK",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_15),
        .tvOS(.v12),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NStackSDK",
            targets: ["NStackSDK"]),
    ],
    dependencies: [
        
        .package(name: "LocalizationManager", url: "https://github.com/nstack-io/localization-manager.git", from: "3.1.2"),
    ],
    
    targets: [
       
        .target(
            name: "NStackSDK",
            dependencies: [
                .product(name: "LocalizationManager", package: "LocalizationManager", condition: .when(platforms: [.iOS, .tvOS])),
            ],
            path: "NStackSDK",
            exclude: ["APIFeedbackManager.swift", "Info.plist"],
            resources: [ .copy("Fallback/Countries.json")]
            ),
        .testTarget(
            name: "NStackSDK Tests",
            dependencies: ["NStackSDK"],
            path: "NStackSDKTests",
            resources: [
                // Copy Tests/ExampleTests/Resources directories as-is.
                // Use to retain directory structure.
                // Will be at top level in bundle.
                .copy("Resources"),
//                .copy("Translations Class"),
            ]
            ),
    ]
)
