// swift-tools-version: 5.11
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetabindUI",
    platforms: [
        .macOS(.v14),
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
    dependencies: [
        .package(url: "https://github.com/exyte/SVGView", from: "1.0.6"),
        .package(url: "https://github.com/warrenm/GLTFKit2", from: "0.5.11")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MetabindUI",
            dependencies: [
                .product(name: "SVGView", package: "SVGView"),
                .product(name: "GLTFKit2", package: "GLTFKit2")
            ],
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
