//
//  DynamoQuery.swift
//  FluentDynamoDBDriver
//
//  Created by Joe Smith on 4/12/19.
//

public enum DynamoQueryAction {
    case set, get, delete
}

public struct DynamoQuery {
    public var action: DynamoQueryAction
    public let table: String
    public let key: DynamoValue

    public init(action: DynamoQueryAction, table: String, key: DynamoValue) {
        self.action = action
        self.table = table
        self.key = key
    }
}
