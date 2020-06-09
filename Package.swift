// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OverlappingViewsSeparator",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(name: "OverlappingViewsSeparator", targets: ["OverlappingViewsSeparator"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "OverlappingViewsSeparator", dependencies: []),
    ]
)
