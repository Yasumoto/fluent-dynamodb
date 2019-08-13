//
//  DynamoQuery.swift
//  FluentDynamoDBDriver
//
//  Created by Joe Smith on 4/12/19.
//

// Good sign of abstraction leakage
import DynamoDB

/// What type of request to make to DynamoDB
public enum DynamoQueryAction {
    case set, get, delete, filter
}

/// 🔎 A DynamoDB operation
// Consider turning this into an enum to support the simple get/put vs. query method
public struct DynamoQuery {

    /// 🏹 Note this is a var so `get/set` can be flipped easily if desired
    public var action: DynamoQueryAction

    /// 🍴 The name of the table in DynamoDB to work on
    public let table: String

    /// ↪️ An optional (Globlal Secondary or Local) Index to query against
    public let index: String?

    /// 💸 Which value(s) to perform the action upon
    public let keys: [DynamoValue]

    public init(action: DynamoQueryAction, table: String, keys: [DynamoValue], index: String? = nil, expressionAttributeNames: [String: String]? = nil, expressionAttributeValues: [String: DynamoDB.AttributeValue]? = nil, keyConditionExpression: String? = nil) {
        self.action = action
        self.table = table
        self.keys = keys
        self.index = index

        self.expressionAttributeNames = expressionAttributeNames
        self.expressionAttributeValues = expressionAttributeValues
        self.keyConditionExpression = keyConditionExpression
    }

// Need to clean these up and figure out a better/simpler way to do queries.
    /// `ExpressionAttributeNames` used when `filter`ing
    public let expressionAttributeNames: [String: String]?
    /// ExpressionAttributeValues used when `filter`ing
    public let expressionAttributeValues: [String: DynamoDB.AttributeValue]?
    /// 🔀 [KeyConditionExpression](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html#API_Query_RequestSyntax) which tells DynamoDB which queries to filter for. Only used when performing a `filter` action.
    public let keyConditionExpression: String?
}
