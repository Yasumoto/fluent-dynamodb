import XCTest

import FluentDynamoDBTests

var tests = [XCTestCaseEntry]()
tests += FluentDynamoDBTests.allTests()
XCTMain(tests)
