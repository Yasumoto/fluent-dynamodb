//
//  DynamoOutput.swift
//  FluentDynamoDBDriver
//
//  Created by Joe Smith on 4/12/19.
//

import DynamoDB

public struct DynamoOutput {
    public let result: [String: DynamoDB.AttributeValue]

    public init(result: [String: DynamoDB.AttributeValue]) {
        self.result = result
    }
}
