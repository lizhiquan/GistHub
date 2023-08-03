// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]
        )
    ],
    dependencies: [
        .package(name: "Models", path: "../Models"),
        .package(name: "AppAccount", path: "../AppAccount"),
        .package(url: "https://github.com/duytph/Networkable", from: "2.0.0"),
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.3.2")
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                "Models",
                "Networkable",
                "AppAccount",
                "GistHubGraphQL",
                .product(name: "Apollo", package: "apollo-ios")
            ]
        ),
        .target(
            name: "GistHubGraphQL",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios")
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"])
    ]
)
