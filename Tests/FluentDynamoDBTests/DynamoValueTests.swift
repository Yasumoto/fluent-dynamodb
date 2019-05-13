import XCTest
@testable import DynamoDB
@testable import FluentDynamoDB

final class DynamoValueTests: XCTestCase {
    func testValueEncoding() {
        let value = DynamoValue(attributes: ["name": .string("jimmeh")])
        let encodedValue = value.encodedKey
        XCTAssertEqual(encodedValue.count, 1)
        XCTAssertEqual(encodedValue["name"]!.s!, "jimmeh")
    }

    func testValueDecoding() {
        let value = DynamoValue(attributes: ["name": DynamoDB.AttributeValue(s: "jimmeh")])
        XCTAssertEqual(value.attributes.count, 1)
        XCTAssertEqual(value.attributes["name"]!, .string("jimmeh"))
    }

    func testCodableSingleValue() throws {
        let value = DynamoValue(attributes: ["name": DynamoDB.AttributeValue(s: "jimmeh")])
        let encodedValue = try JSONEncoder().encode(value)
        let stringValue = String(data: encodedValue, encoding: .utf8)!
        XCTAssertEqual(#"{"name":"jimmeh"}"#, stringValue)
        let decodedValue = try JSONDecoder().decode(DynamoValue.self, from: encodedValue)
        XCTAssertEqual(decodedValue, value)
    }

    func testCodableKeyedValue() throws {
        let value = DynamoValue(attributes: ["name_list": DynamoDB.AttributeValue(ss: ["gimmeh", "jimmeh", "himmeh"])])
        let encodedValue = try JSONEncoder().encode(value)
        let stringValue = String(data: encodedValue, encoding: .utf8)!
        XCTAssertEqual(#"{"name_list":["gimmeh","jimmeh","himmeh"]}"#, stringValue)
        let decodedValue = try JSONDecoder().decode(DynamoValue.self, from: encodedValue)
        XCTAssertEqual(decodedValue, value)
    }

    func testCodableMappedValue() throws {
        let value = DynamoValue(attributes: ["favorite_burgers": DynamoDB.AttributeValue(m: ["jimmeh": DynamoDB.AttributeValue(s: "Five Guys"), "dan": DynamoDB.AttributeValue(s: "In-N-Out")])])
        let encodedValue = try JSONEncoder().encode(value)
        let stringValue = String(data: encodedValue, encoding: .utf8)!
        let options = [
        #"{"favorite_burgers":{"dan":"In-N-Out","jimmeh":"Five Guys"}}"#,
        #"{"favorite_burgers":{"jimmeh":"Five Guys","dan":"In-N-Out"}}"#
        ]
        XCTAssert(options.contains(stringValue))
        let decodedValue = try JSONDecoder().decode(DynamoValue.self, from: encodedValue)
        XCTAssertEqual(decodedValue, value)
    }

    static var allTests = [
        ("testValueEncoding", testValueEncoding),
        ("testValueDecoding", testValueDecoding),
        ("testCodableSingleValue", testCodableSingleValue),
        ("testCodableKeyedValue", testCodableKeyedValue),
        ("testCodableMappedValue", testCodableMappedValue)
    ]
}
