import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(nstack_ios_sdkTests.allTests),
    ]
}
#endif
