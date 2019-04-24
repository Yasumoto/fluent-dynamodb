//
//  DynamoDatabase+LogSupporting.swift
//  FluentDynamoDB
//
//  Created by Joe Smith on 4/23/19.
//

import DatabaseKit

extension DynamoDatabase: LogSupporting {
    /// See `LogSupporting`.
    public static func enableLogging(_ logger: DatabaseLogger, on conn: DynamoConnection) {
        conn.logger = logger
    }
}
