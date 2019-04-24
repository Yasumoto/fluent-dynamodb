//
//  DynamoOutput.swift
//  FluentDynamoDB
//
//  Created by Joe Smith on 4/12/19.
//

import DynamoDB

public struct DynamoOutput {
    public let result: DynamoValue?

    public init(result: [String: DynamoDB.AttributeValue]?) {
        self.result = DynamoValue(attributes: result)
    }
}
