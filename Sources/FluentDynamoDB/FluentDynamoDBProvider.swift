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
        try services.register(FluentProvider())

        // Basing this off the `PostgreSQLProvider
        // https://github.com/vapor/postgresql/blob/1.4.1/Sources/PostgreSQL/Utilities/PostgreSQLProvider.swift#L10
        var databases = DatabasesConfig()
        databases.add(database: DynamoDatabase.self, as: .dynamo)
        services.register(databases)
    }
    
    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
    
    public init() { }
}

extension DynamoDatabase: Service { }
