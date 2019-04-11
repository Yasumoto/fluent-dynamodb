import XCTest

import FluentDynamoDBDriverTests

var tests = [XCTestCaseEntry]()
tests += FluentDynamoDBDriverTests.allTests()
XCTMain(tests)
