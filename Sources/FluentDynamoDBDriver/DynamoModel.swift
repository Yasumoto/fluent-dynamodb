//
//  DynamoModel.swift
//  fluent-dynamodb-driver
//
//  Created by Joe Smith on 4/10/19.
//

/// A Dynamo database model.
/// See `Fluent.Model`.
public protocol DynamoModel: _DynamoModel {
    /// This SQLite Model's unique identifier.
    var id: ID? { get set }
}

/// Base SQLite model protocol.
public protocol _DynamoModel: DynamoDB, Model where Self.Database == SQLiteDatabase { }

extension SQLiteModel {
    /// See `Model`
    public static var idKey: IDKey { return \.id }
}
