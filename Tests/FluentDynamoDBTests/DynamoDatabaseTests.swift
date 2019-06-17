//
//  DynamoDatabaseTests.swift
//  
//
//  Created by Joe Smith on 6/11/19.
//

@testable import FluentDynamoDB

import NIO
import XCTest

// TODO: Mock out the underlying DynamoDB client
final class DynamoDatabaseTests: XCTestCase {
    let config = DynamoConfiguration(accessKeyId: "test", secretAccessKey: "test")
    func testDatabaseCreation() throws {
        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let database = DynamoDatabase(config: config)
        let _ = try database.newConnection(on: worker).wait()
    }

    static var allTests = [
        ("testDatabaseCreation", testDatabaseCreation)
    ]
}
