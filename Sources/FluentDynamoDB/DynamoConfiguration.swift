//
//  DynamoConfiguration.swift
//  fluent-dynamodb
//
//  Created by Joe Smith on 4/9/19.
//

@_exported import enum AWSSDKSwiftCore.Region

public struct DynamoConfiguration {
    public let accessKeyId: String?
    public let secretAccessKey: String?
    public let region: Region?
    public let endpoint: String?

    public init(accessKeyId: String?, secretAccessKey: String?, region: Region?, endpoint: String?) {
        self.accessKeyId = accessKeyId
        self.secretAccessKey = secretAccessKey
        self.region = region
        self.endpoint = endpoint
    }
}

