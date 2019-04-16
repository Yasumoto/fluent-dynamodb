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
    public let keyName: String
    public let keyValue: String
}
