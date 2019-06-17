//
//  DynamoConnection.swift
//  FluentDynamoDB
//
//  Created by Joe Smith on 4/9/19.
//

import DatabaseKit
import DynamoDB

public enum DynamoConnectionError: Error {
    case improperlyFormattedQuery(String)
    case notImplementedYet
}

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
    public func query(_ query: Query, _ handler: @escaping (Output) throws -> ()) -> Future<Void> {
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
                let inputItem = DynamoDB.PutItemInput(item: query.key.encodedKey, returnValues: .allOld, tableName: query.table)
                return try self.handle.putItem(inputItem).map { output in
                    return try handler(Output(attributes: output.attributes))
                }
            case .delete:
                let inputItem: DynamoDB.DeleteItemInput = DynamoDB.DeleteItemInput(
                    key: query.key.encodedKey, returnValues: .allOld, tableName: query.table)
                return try self.handle.deleteItem(inputItem).map { output in
                    return try handler(DynamoValue(attributes: output.attributes))
                }
            }
        } catch {
            return self.eventLoop.newFailedFuture(error: error)
        }
    }


    /// 🧳 Batch request for several items in DynamoDB
    ///
    /// This takes advantage of the `Batch` operations in Dynamo to operate on several values at
    /// once.
    ///
    /// - Parameters:
    ///     - query: The DynamoQuery used to request items. You *must* set `DynamoQuery.keys`!
    ///
    /// - Returns:
    ///     EventLoopFuture with a list of `DynamoValue`s from the table in the `DynamoQuery`.
    public func query(_ query: Query) -> Future<[Output]> {
        self.logger?.record(query: String(describing: query))
        do {
            switch query.action {
            case .get:
                guard let keys = query.keys else {
                    // Probably a better way to flip between a query for one item vs. several,
                    // maybe `DynamoQuery.key` is always a list?
                    throw DynamoConnectionError.improperlyFormattedQuery("Please set `DynamoQuery.keys` to query multiple items.")
                }
                let attributes = keys.map { (key: DynamoValue) -> [String: DynamoDB.AttributeValue] in
                    key.encodedKey
                }
                let keysAndAttributes = DynamoDB.KeysAndAttributes(keys: attributes)
                let batchInput = DynamoDB.BatchGetItemInput(requestItems: [query.table: keysAndAttributes])

                // Note that DynamoDB allows batch operations to query multiple items. For simplicity, we're
                // always assuming we're querying one table at a time. We will always check the response for
                // the table name we've specified in the query itself.
                return try self.handle.batchGetItem(batchInput).map { (output: DynamoDB.BatchGetItemOutput) -> [DynamoValue] in
                    guard let values: [[String : DynamoDB.AttributeValue]] = output.responses?[query.table] else { return [DynamoValue]() }
                    return values.map { DynamoValue(attributes: $0) }
                }
            case .set:
                throw DynamoConnectionError.notImplementedYet

            case .delete:
                throw DynamoConnectionError.notImplementedYet
            }
        } catch {
            return self.eventLoop.newFailedFuture(error: error)
        }
    }
}
