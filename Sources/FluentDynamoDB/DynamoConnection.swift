//
//  DynamoConnection.swift
//  FluentDynamoDB
//
//  Created by Joe Smith on 4/9/19.
//

import DatabaseKit
import DynamoDB

/// 💫 `DatabaseConnection` for direct queries to DynamoDB.
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

    /// 📖 Submit request to DynamoDB
    ///
    /// The Future signals completion, and the handler will run upon success.
    /// Note for .set and .delete queries, the handler will be called with the *old* values
    /// that have been replaced!
    public func query(_ query: Query, _ handler: @escaping (Output) throws -> ()) -> Future<Void>{
        self.logger?.record(query: String(describing: query))
        do {
            switch query.action {
            case .get:
                let inputItem = DynamoDB.GetItemInput(
                    key: query.key.encodedKey, tableName: query.table)
                return try self.handle.getItem(inputItem).map { output in
                    return try handler(Output(attributes: output.item))
                }
            case .set:
                let input = DynamoDB.PutItemInput(
                    tableName: query.table, item: query.key.encodedKey, returnValues: .allOld)
                return try self.handle.putItem(input).map { output in
                    return try handler(Output(attributes: output.attributes))
                }
            case .delete:
                let input = DynamoDB.DeleteItemInput(
                    key: query.key.encodedKey, tableName: query.table, returnValues: .allOld)
                return try self.handle.deleteItem(input).map { output in
                    return try handler(DynamoValue(attributes: output.attributes))
                }
            }
        } catch {
            return self.eventLoop.newFailedFuture(error: error)
        }
    }
}
