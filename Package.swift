// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReactiveSwift",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .macCatalyst(.v26),
        .watchOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "ReactiveSwift",
            targets: [
                "ReactiveSwift"
            ]
        ),
    ],
    targets: [
        .target(
            name: "ReactiveSwift",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "ReactiveSwiftTests",
            dependencies: ["ReactiveSwift"],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
    ]
)
