import XCTest
@testable import DynamoDB
@testable import FluentDynamoDB

final class FluentDynamoDBTests: XCTestCase {
    func testValueEncoding() {
        let value = DynamoValue(attributes: ["key": .string("jimmeh")])
        let encodedValue = value.encodedKey
        XCTAssertEqual(encodedValue.count, 1)
        XCTAssertEqual(encodedValue["key"]!.s!, "jimmeh")
    }

    func testValueDecoding() {
        let value = DynamoValue(attributes: ["key": DynamoDB.AttributeValue(s: "jimmeh")])
        XCTAssertEqual(value.attributes.count, 1)
        XCTAssertEqual(value.attributes["key"]!, .string("jimmeh"))
    }

    static var allTests = [
        ("testValueEncoding", testValueEncoding),
        ("testValueDecoding", testValueDecoding)
    ]
}
