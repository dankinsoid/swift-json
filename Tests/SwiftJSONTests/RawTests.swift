import SwiftJSON
import XCTest

class RawTests: XCTestCase {

	func testRawData() {
		let json: JSON = ["somekey": "some string value"]
		let expectedRawData = "{\"somekey\":\"some string value\"}"
		XCTAssertEqual(json.utf8String, expectedRawData)
	}

	func testInvalidJSONForRawData() {
		let json: JSON = "...<nonsense>xyz</nonsense>"
		XCTAssertEqual(json.utf8String, "\"...<nonsense>xyz</nonsense>\"")
	}

	func testArray() {
		let json: JSON = [1, "2", 3.12, .null, true, ["name": "Jack"]]
		let data = json.data
		let string = json.utf8String
		XCTAssertFalse(data.isEmpty)
		XCTAssertTrue(string.lengthOfBytes(using: String.Encoding.utf8) > 0)
	}

	func testDictionary() {
		let json: JSON = ["number": 111_111.23456789, "name": "Jack", "list": [1, 2, 3, 4], "bool": false, "null": .null]
		let data = json.data
		let string = json.utf8String
		XCTAssertFalse(data.isEmpty)
		XCTAssertTrue(string.lengthOfBytes(using: String.Encoding.utf8) > 0)
	}

	func testString() {
		let json: JSON = "I'm a json"
		XCTAssertEqual(json.description, "\"I'm a json\"")
	}

	func testBool() {
		let json: JSON = true
		XCTAssertEqual(json.description, "true")
	}

	func testNull() {
		let json = JSON.null
		XCTAssertEqual(json.description, "null")
	}

	func testNestedJSON() {
		let inner: JSON = ["name": "john doe"]
		let json: JSON = ["level": 1337, "user": inner]
		let data = json.data
		let string = json.utf8String
		XCTAssertFalse(data.isEmpty)
		XCTAssertTrue(string.lengthOfBytes(using: String.Encoding.utf8) > 0)
	}
}
