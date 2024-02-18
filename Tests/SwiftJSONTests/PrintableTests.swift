import SwiftJSON
import XCTest

class PrintableTests: XCTestCase {
	func testNumber() {
		let json: JSON = 1_234_567_890.876623
		XCTAssertEqual(json.description, "1234567890.8766230528")
	}

	func testBool() {
		let jsonTrue: JSON = true
		XCTAssertEqual(jsonTrue.description, "true")
		let jsonFalse: JSON = false
		XCTAssertEqual(jsonFalse.description, "false")
	}

	func testString() {
		let json: JSON = "abcd efg, HIJK;LMn"
		XCTAssertEqual(json.description, "\"abcd efg, HIJK;LMn\"")
	}

	func testNil() {
		let jsonNil_1 = JSON.null
		XCTAssertEqual(jsonNil_1.description, "null")
	}

	func testArray() {
		let json: JSON = [1, 2, "4", 5, "6"]
		var description = json.description.replacingOccurrences(of: "\n", with: "")
		description = description.replacingOccurrences(of: " ", with: "")
		XCTAssertEqual(description, "[1,2,\"4\",5,\"6\"]")
		XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
	}

	func testArrayWithStrings() {
		let array = ["\"123\""]
		let json = JSON(array).orNull
		var description = json.utf8String.replacingOccurrences(of: "\n", with: "")
		description = description.replacingOccurrences(of: " ", with: "")
		XCTAssertEqual(description, "[\"\\\"123\\\"\"]")
		XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
	}

	func testArrayWithOptionals() {
		let array = [1, 2, "4", 5, "6", nil] as [Any?]
		let json = JSON(array)
		guard var description = json?.description else {
			XCTFail("could not represent array")
			return
		}
		description = description.replacingOccurrences(of: "\n", with: "")
		description = description.replacingOccurrences(of: " ", with: "")
		XCTAssertEqual(description, "[1,2,\"4\",5,\"6\",null]")
	}

	func testDictionary() {
		let json: JSON = ["1": 2, "2": "two", "3": 3]
		var debugDescription = json.description.replacingOccurrences(of: "\n", with: "")
		debugDescription = debugDescription.replacingOccurrences(of: " ", with: "")
		XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
		XCTAssertTrue(debugDescription.range(of: "\"1\":2", options: String.CompareOptions.caseInsensitive) != nil)
		XCTAssertTrue(debugDescription.range(of: "\"2\":\"two\"", options: String.CompareOptions.caseInsensitive) != nil)
		XCTAssertTrue(debugDescription.range(of: "\"3\":3", options: String.CompareOptions.caseInsensitive) != nil)
	}

	func testDictionaryWithStrings() {
		let dict = ["foo": "{\"bar\":123}"] as [String: Any]
		let json = JSON(dict).orNull
		let debugDescription = json.utf8String
		XCTAssertTrue(json.description.lengthOfBytes(using: String.Encoding.utf8) > 0)
		let exceptedResult = "{\"foo\":\"{\\\"bar\\\":123}\"}"
		XCTAssertEqual(debugDescription, exceptedResult)
	}

	func testDictionaryWithOptionals() {
		let dict = ["1": 2, "2": "two", "3": nil] as [String: Any?]
		let json = JSON(dict)
		guard let description = json?.utf8String else {
			XCTFail("could not represent dictionary")
			return
		}
		XCTAssertTrue(description.range(of: "\"1\":2", options: NSString.CompareOptions.caseInsensitive) != nil)
		XCTAssertTrue(description.range(of: "\"2\":\"two\"", options: NSString.CompareOptions.caseInsensitive) != nil)
		XCTAssertTrue(description.range(of: "\"3\":null", options: NSString.CompareOptions.caseInsensitive) != nil)
	}
}
