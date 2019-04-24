//
//  DynamoDatabase.swift
//  FluentDynamoDB
//
//  Created by Joe Smith on 4/9/19.
//

import DynamoDB
import DatabaseKit

public final class DynamoDatabase: Database {
    public typealias Connection = DynamoConnection
    public typealias Query = DynamoQuery
    public typealias Output = DynamoOutput

    private let config: DynamoConfiguration

    internal func openConnection() -> DynamoDB {
        return DynamoDB(accessKeyId: config.accessKeyId, secretAccessKey: config.secretAccessKey, region: config.region, endpoint: config.endpoint)
    }
    
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
        return .init("dynamo")
    }
}
