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
    func register(_ services: inout Services) throws {
        try services.register(FluentProvider())

        let dynamoAccessKey = Environment.get("DYNAMO_ACCCESS_KEY")
        let dynamoPrivateKey = Environment.get("DYNAMO_SECRET_KEY")
        let dynamoConfiguration = DynamoConfiguration(accessKeyId: dynamoAccessKey, secretAccessKey: dynamoPrivateKey, region: .useast1, endpoint: nil)
        services.register(DynamoDatabase(config: dynamoConfiguration))
    }
    
    func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
    
    public init() { }
}

extension DynamoDatabase: Service { }
