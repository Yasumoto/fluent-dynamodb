//
//  DynamoConnection.swift
//  fluent-dynamodb-driver
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
    
    public func query(_ query: Query, _ handler: @escaping (Output) throws -> ()) -> Future<Void>{
        let result = self.eventLoop.newPromise(of: Void.self)
        self.eventLoop.execute {
        switch query.action {
        case .get:
            let attributeValue = DynamoDB.AttributeValue.init(m: nil, null: nil, ss: nil, b: nil, s: query.keyValue, l: nil, bool: nil, ns: nil, bs: nil, n: nil)
            let inputItem = DynamoDB.GetItemInput(key: [query.keyName: attributeValue], tableName: query.table)
            do {
                let response = try self.handle.getItem(inputItem)
                let _ = response.map { output in
                    if let item = output.item {
                        try handler(DynamoOutput(result: item))
                    }
                    result.succeed()
                }
            } catch {
                result.fail(error: error)
            }
        case .set:
            let lockKeyAttribute = DynamoDB.AttributeValue(m: nil, null: nil, ss: nil, b: nil, s: query.keyValue, l: nil, bool: nil, ns: nil, bs: nil, n: nil)
            let input = DynamoDB.PutItemInput(returnConsumedCapacity: nil, conditionalOperator: nil, conditionExpression: nil, tableName: query.table, expressionAttributeValues: nil, item: [query.keyName : lockKeyAttribute], expected: nil, returnValues: nil, returnItemCollectionMetrics: nil, expressionAttributeNames: nil)
            do {
                let response = try self.handle.putItem(input)
                let _ = response.map { output in
                    if let attributes = output.attributes {
                        try handler(DynamoOutput(result: attributes))
                    }
                    result.succeed()
                }

            } catch {
                result.fail(error: error)
            }
            print("set")
        case .delete:
            print("delete")
        }
        }
        return result.futureResult
    }
}
