//
//  FluentDynamoDBProvider.swift
//  FluentDynamoDB
//
//  Created by Joe Smith on 4/23/19.
//

import Fluent

/// 💧 The Provider expected to be registered to easily allow
/// usage of DynamoDB from within a Vapor application
/// Note you MUST specify credentials via environment variables:
/// DYNAMO_ACCCESS_KEY: AWS Access Key to write to all tables you will use
/// DYNAMO_SECRET_KEY: Secret Key for the AWS user
public struct FluentDynamoDBProvider: Provider {
    public func register(_ services: inout Services) throws {
        // Use Fluent if/when you get migration support
        try services.register(DatabaseKitProvider())

        // Basing this off the `PostgreSQLProvider
        // https://github.com/vapor/postgresql/blob/1.4.1/Sources/PostgreSQL/Utilities/PostgreSQLProvider.swift#L10
        services.register(DynamoConfiguration.self)
        services.register(DynamoDatabase.self)
        var databases = DatabasesConfig()
        databases.add(database: DynamoDatabase.self, as: .dynamo)
        services.register(databases)
    }
    
    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
    
    public init() { }
}

/// MARK: Services

extension DynamoConfiguration: ServiceType {
    public static func makeService(for container: Container) throws -> DynamoConfiguration {
        return DynamoConfiguration(accessKeyId: nil, secretAccessKey: nil, region: nil, endpoint: nil)
    }
}

extension DynamoDatabase: ServiceType {
    public static func makeService(for container: Container) throws -> Self {
        return try .init(config: container.make())
    }
}
