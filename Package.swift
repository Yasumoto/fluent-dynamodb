// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fluent-dynamodb-driver",
    products: [
        .library(
            name: "FluentDynamoDBDriver",
            targets: ["FluentDynamoDBDriver"])
    ],
    dependencies: [
        // *️⃣  ORM to integrate with Vapor
        .package(url: "https://github.com/vapor/fluent", from: "3.1.0"),

        // 🌟 AWS Core Lib
        .package(url: "https://github.com/swift-aws/aws-sdk-swift-core", .branch("invokeAsync")),

        // 💫 AWS Client Library
        .package(url: "https://github.com/swift-aws/aws-sdk-swift", .branch("return_futures")),
    ],
    targets: [
        .target(
            name: "FluentDynamoDBDriver",
            dependencies: ["DynamoDB", "Fluent"]),
        .testTarget(
            name: "FluentDynamoDBDriverTests",
            dependencies: ["FluentDynamoDBDriver"])
    ]
)
