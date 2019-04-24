//
//  DynamoDatabase.swift
//  FluentDynamoDB
//
//  Created by Joe Smith on 4/9/19.
//

import DynamoDB
import DatabaseKit

/// 📦 `Database` implementation for DynamoDB
public final class DynamoDatabase: Database {
    public typealias Connection = DynamoConnection
    public typealias Query = DynamoQuery
    public typealias Output = DynamoValue

    private let config: DynamoConfiguration

    // Create a new DynamoDB
    internal func openConnection() -> DynamoDB {
        return DynamoDB(accessKeyId: config.accessKeyId, secretAccessKey: config.secretAccessKey, region: config.region, endpoint: config.endpoint)
    }

    /// Create a new client for communicating with DynamoDB
    public func newConnection(on worker: Worker) -> EventLoopFuture<DynamoConnection> {
        do {
            let conn = try DynamoConnection(database: self, on: worker)
            return worker.future(conn)
        } catch {
            return worker.future(error: error)
        }
    }
    
    public init(config: DynamoConfiguration) {
        self.config = config
    }
}

extension DatabaseIdentifier {
    /// Default identifier for `DynamoDatabase`.
    public static var dynamo: DatabaseIdentifier<DynamoDatabase> {
        return "dynamo"
    }
}
