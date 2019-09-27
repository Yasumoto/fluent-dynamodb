// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "fluent-dynamodb",
    products: [
        .library(
            name: "FluentDynamoDB",
            targets: ["FluentDynamoDB"])
    ],
    dependencies: [
        // *️⃣  ORM to integrate with Vapor
        .package(url: "https://github.com/vapor/fluent", from: "3.1.0"),

        // 💫 AWS Client Library
        .package(url: "https://github.com/swift-aws/aws-sdk-swift", from: "3.2.0"),

        // 💫 AWS Client Library
        .package(url: "https://github.com/swift-aws/aws-sdk-swift-core", .branch("yasumoto-5.1")),
    ],
    targets: [
        .target(
            name: "FluentDynamoDB",
            dependencies: ["DynamoDB", "Fluent"]),
        .testTarget(
            name: "FluentDynamoDBTests",
            dependencies: ["FluentDynamoDB"])
    ]
)
