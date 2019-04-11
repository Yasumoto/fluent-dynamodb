import XCTest
@testable import FluentDynamoDBDriver

final class FluentDynamoDBDriverTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FluentDynamoDBDriver().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
