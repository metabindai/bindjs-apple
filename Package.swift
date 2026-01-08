// swift-tools-version: 5.11
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "bindjs-apple",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v6),
        .tvOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BindJS",
            targets: ["BindJS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/yapstudios/SVGView.git", from: "1.0.7"),
        .package(url: "https://github.com/warrenm/GLTFKit2", from: "0.5.11")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BindJS",
            dependencies: [
                .product(name: "SVGViewKit", package: "SVGView"),
                .product(name: "GLTFKit2", package: "GLTFKit2")
            ],
            resources: [
                .copy("Resources/BindJSRuntime.js"),
                .copy("Resources/BindJSRuntimeWrapper.js")
            ]
        ),
    ]
)
