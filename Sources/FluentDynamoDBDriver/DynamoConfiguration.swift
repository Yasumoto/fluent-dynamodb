//
//  DynamoConfiguration.swift
//  fluent-dynamodb-driver
//
//  Created by Joe Smith on 4/9/19.
//

@_exported import enum AWSSDKSwiftCore.Region

public struct DynamoConfiguration {
    let accessKeyId: String?
    let secretAccessKey: String?
    let region: Region?
    let endpoint: String?
}
