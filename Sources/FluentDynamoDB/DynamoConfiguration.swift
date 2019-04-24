//
//  DynamoConfiguration.swift
//  fluent-dynamodb
//
//  Created by Joe Smith on 4/9/19.
//

@_exported import enum AWSSDKSwiftCore.Region

/// 📝 Necessary setup for connecting to DynamoDB
public struct DynamoConfiguration {
    /// Hardcoded Access Key identifying a user in IAM
    public let accessKeyId: String?

    /// Corresponding Secret Key
    public let secretAccessKey: String?

    /// Specific region in AWS to connect to
    /// Defaults to us-east-1
    public let region: Region?

    /// Optional endpoint to connect to
    public let endpoint: String?

    public init(accessKeyId: String?, secretAccessKey: String?, region: Region? = .useast1, endpoint: String? = nil) {
        self.accessKeyId = accessKeyId
        self.secretAccessKey = secretAccessKey
        self.region = region
        self.endpoint = endpoint
    }
}

