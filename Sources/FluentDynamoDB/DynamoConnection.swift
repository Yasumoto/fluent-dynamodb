//
//  DynamoConnection.swift
//  FluentDynamoDB
//
//  Created by Joe Smith on 4/9/19.
//

import DatabaseKit
import DynamoDB

/// TODO(jmsmith): Can we get away without a connection since that doesn't technically exist?
public final class DynamoConnection: BasicWorker, DatabaseConnection {
    
    /// See `DatabaseConnection`.
    public typealias Database = DynamoDatabase

    /// See `DatabaseConnection`.
    public var isClosed: Bool {
        return false
    }

    /// See `DatabaseConnection`.
    public func close() {
        // TODO(jmsmith): The request/response nature of DynamoDB doesn't lend
        // itself well here, does it?
    }
    
    /// See `DatabaseConnection`.
    public var extend: Extend
    
    /// See `BasicWorker`.
    public let eventLoop: EventLoop

    /// Reference to parent `DynamoDatabase` that created this connection.
    /// This reference will ensure the DB stays alive since this connection uses
    /// it's thread pool.
    private let database: DynamoDatabase

    /// If non-nil, will log queries.
    public var logger: DatabaseLogger?
    
    internal private(set) var handle: DynamoDB!

    internal init(database: DynamoDatabase, on worker: Worker) throws {
        self.extend = [:]
        self.database = database
        self.eventLoop = worker.eventLoop
        self.handle = database.openConnection()
    }
}

extension DynamoConnection: DatabaseQueryable {
    public typealias Query = Database.Query
    
    public typealias Output = Database.Output

    /// Note that if the `handler` blocks, the promise will never succeed.
    /// This may be unexpected behavior.
    public func query(_ query: Query, _ handler: @escaping (Output) throws -> ()) -> Future<Void>{
        self.logger?.record(query: String(describing: query))
        let promise = self.eventLoop.newPromise(Void.self)
        do {
            switch query.action {
            case .get:
                let inputItem = DynamoDB.GetItemInput(key: query.key.encodedKey, tableName: query.table)
                let _ = try self.handle.getItem(inputItem).map { output in
                    try handler(DynamoOutput(result: output.item))
                    promise.succeed()
                }
            case .set:
                let input = DynamoDB.PutItemInput(returnConsumedCapacity: nil, conditionalOperator: nil, conditionExpression: nil, tableName: query.table, expressionAttributeValues: nil, item: query.key.encodedKey, expected: nil, returnValues: nil, returnItemCollectionMetrics: nil, expressionAttributeNames: nil)
                let _ = try self.handle.putItem(input).map { output in
                    try handler(DynamoOutput(result: output.attributes))
                    promise.succeed()
                }
            case .delete:
                let input = DynamoDB.DeleteItemInput(key: query.key.encodedKey, tableName: query.table)
                let _ = try self.handle.deleteItem(input).map { output in
                    try handler(DynamoOutput(result: output.attributes))
                    promise.succeed()
                }
            }
        } catch {
            promise.fail(error: error)
        }
        return promise.futureResult
    }
}
