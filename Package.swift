// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NStackSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NStackSDK",
            targets: ["NStackSDK"]),
    ],
    dependencies: [
        
        .package(name: "LocalizationManager", url: "https://github.com/nodes-ios/TranslationManager", from: "3.1.2"),
    ],
    
    targets: [
       
        .target(
            name: "NStackSDK",
            dependencies: [
                .product(name: "LocalizationManager", package: "LocalizationManager", condition: .when(platforms: [.iOS])),
            ],
            path: "NStackSDK",
            exclude: ["APIFeedbackManager.swift"]
            ),
        .testTarget(
            name: "NStackSDK Tests",
            dependencies: ["NStackSDK"],
            path: "NStackSDKTests"
            ),
    ]
)
