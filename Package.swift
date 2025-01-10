// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TabachnikUI",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TabachnikUI",
            targets: ["TabachnikUI"]
        ),
    ],
    dependencies: [
        // Declare the Kingfisher package as a dependency
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TabachnikUI",
            dependencies: ["Kingfisher"]
        ),
        .testTarget(
            name: "TabachnikUITests",
            dependencies: ["TabachnikUI"]
        ),
    ]
)
