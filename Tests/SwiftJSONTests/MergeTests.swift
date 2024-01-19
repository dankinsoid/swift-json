import SwiftJSON
import XCTest

class MergeTests: XCTestCase {

	func testDifferingTypes() {
		let A: JSON = "a"
		let B: JSON = 1

		do {
			_ = try A.merged(with: B)
		} catch is WrongType {
		} catch _ {
			XCTFail("Wrong error thrown")
		}
	}

	func testPrimitiveType() throws {
		let A: JSON = "a"
		let B: JSON = "b"
		XCTAssertEqual(try A.merged(with: B), B)
	}

	func testMergeEqual() throws {
		let json: JSON = ["a": "A"]
		XCTAssertEqual(try json.merged(with: json), json)
	}

	func testMergeUnequalValues() throws {
		let A: JSON = ["a": "A"]
		let B: JSON = ["a": "B"]
		XCTAssertEqual(try A.merged(with: B), B)
	}

	func testMergeUnequalKeysAndValues() throws {
		let A: JSON = ["a": "A"]
		let B: JSON = ["b": "B"]
		XCTAssertEqual(try A.merged(with: B), JSON(["a": "A", "b": "B"]))
	}

	func testMergeFilledAndEmpty() throws {
		let A: JSON = ["a": "A"]
		let B: JSON = [:]
		XCTAssertEqual(try A.merged(with: B), A)
	}

	func testMergeEmptyAndFilled() throws {
		let A: JSON = [:]
		let B: JSON = ["a": "A"]
		XCTAssertEqual(try A.merged(with: B), B)
	}

	func testMergeArray() throws {
		let A: JSON = ["a"]
		let B: JSON = ["b"]
		XCTAssertEqual(try A.merged(with: B), JSON(["a", "b"]))
	}

	func testMergeNestedJSONs() throws {
		let A: JSON = [
			"nested": [
				"A": "a",
			],
		]

		let B: JSON = [
			"nested": [
				"A": "b",
			],
		]

		XCTAssertEqual(try A.merged(with: B), B)
	}
}
