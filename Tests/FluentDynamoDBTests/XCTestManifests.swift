import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DynamoDatabaseTests.allTests),
        testCase(DynamoValueTests.allTests),
    ]
}
#endif
