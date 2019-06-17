//
//  DynamoQuery.swift
//  FluentDynamoDBDriver
//
//  Created by Joe Smith on 4/12/19.
//

/// What type of request to make to DynamoDB
public enum DynamoQueryAction {
    case set, get, delete
}

/// 🔎 A DynamoDB operation
// Consider turning this into an enum to support the simple get/put vs. query method
public struct DynamoQuery {

    /// Note this is a var so `get/set` can be flipped easily if desired
    public var action: DynamoQueryAction

    /// The name of the table in DynamoDB to work on
    public let table: String

    // Which value to perform the action upon
    public let key: DynamoValue

    public init(action: DynamoQueryAction, table: String, key: DynamoValue) {
        self.action = action
        self.table = table
        self.key = key
    }

    /// Support for batch operations
    // Maybe just have one `key` (and delete the below) which is `[DynamoValue]`?
    public var keys: [DynamoValue]? = nil
}
