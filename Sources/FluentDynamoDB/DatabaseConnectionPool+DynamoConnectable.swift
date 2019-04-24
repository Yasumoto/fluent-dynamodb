//
//  DatabaseConnectionPool+DynamoConnectable.swift
//  FluentDynamoDB
//
//  Created by Joe Smith on 4/23/19.
//

import DatabaseKit

/// Capable of creating connections to DynamoDB.
public protocol DynamoConnectable {
    /// Associated database connection type.
    associatedtype Connection: DynamoConnection

    /// Calls the supplied closure asynchronously with a database connection.
    func withDynamoConnection<T>(_ closure: @escaping (Connection) -> (Future<T>)) -> Future<T>
}

extension DynamoConnection {
    /// See `DynamoConnectable`.
    public func withDynamoConnection<T>(_ closure: @escaping (Database.Connection) -> (Future<T>)) -> Future<T> {
        return closure(self)
    }
}

extension DatabaseConnectionPool: DynamoConnectable where
    Database.Connection: DynamoConnection
{
    /// See `DynamoConnectable`.
    public typealias Connection = Database.Connection

    /// See `DynamoConnectable`.
    public func withDynamoConnection<T>(_ closure: @escaping (Database.Connection) -> (Future<T>)) -> Future<T> {
        return withConnection { closure($0) }
    }
}
