// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MARS",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MARS",
            targets: ["MARS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics.git", .upToNextMajor(from: "1.0.2")),
        .package(url: "https://github.com/elai950/AlertToast.git", .upToNextMajor(from: "1.3.9"))
    ],
    targets: [
        .target(
            name: "MARS",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "AlertToast", package: "AlertToast")
            ]),
        .testTarget(
            name: "MARSTests",
            dependencies: ["MARS"]),
    ]
)
