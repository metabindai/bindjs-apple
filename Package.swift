// swift-tools-version: 5.11
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetabindUI",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v6),
        .tvOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MetabindUI",
            targets: ["MetabindUI"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MetabindUI",
            resources: [
                .copy("Resources/JSRuntime.js")
            ]
        ),
        .testTarget(
            name: "MetabindUITests",
            dependencies: ["MetabindUI"]
        ),
    ]
)
