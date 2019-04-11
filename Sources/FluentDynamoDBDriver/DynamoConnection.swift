//
//  DynamoConnection.swift
//  fluent-dynamodb-driver
//
//  Created by Joe Smith on 4/9/19.
//

import DatabaseKit
import DynamoDB

/// TODO(jmsmith): Can we get away without a connection since that doesn't technically exist?
public final class DynamoConnection: BasicWorker, DatabaseConnection, DatabaseQueryable {
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
    
    // DatabaseQueryable
    public typealias Query = <#type#>
    
    public typealias Output = <#type#>
}
