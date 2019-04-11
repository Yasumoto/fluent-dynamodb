//
//  DynamoDatabase.swift
//  fluent-dynamodb-driver
//
//  Created by Joe Smith on 4/9/19.
//

import DynamoDB
import DatabaseKit

public final class DynamoDatabase: Database {
    public typealias Connection = DynamoConnection

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
