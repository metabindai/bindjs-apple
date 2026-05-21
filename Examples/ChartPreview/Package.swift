// swift-tools-version: 5.11
import PackageDescription

let package = Package(
    name: "BindJSChartPreview",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "BindJSChartPreview", targets: ["BindJSChartPreview"])
    ],
    dependencies: [
        .package(name: "bindjs-apple", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "BindJSChartPreview",
            dependencies: [
                .product(name: "BindJS", package: "bindjs-apple")
            ]
        )
    ]
)
