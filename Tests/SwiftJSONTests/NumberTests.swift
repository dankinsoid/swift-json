import SwiftJSON
import XCTest

class NumberTests: XCTestCase {

	func testNumber() {
		// getter
		var json = JSON(9_876_543_210.123456789).orNull
		XCTAssertEqual(json.number!, 9_876_543_210.123456789)
		XCTAssertEqual(json.numberValue, 9_876_543_210.123456789)
		XCTAssertEqual(json.stringValue, "9876543210.123457")

		json.string = "1000000000000000000000000000.1"
		XCTAssertNil(json.number)
		XCTAssertEqual(json.numberValue.description, "1000000000000000000000000000.1")

		json.string = "1e+27"
		XCTAssertEqual(json.numberValue.description, "1000000000000000000000000000")

		// setter
		json.number = 123_456_789.0987654321
		XCTAssertEqual(json.number!, 123_456_789.0987654321)
		XCTAssertEqual(json.numberValue, 123_456_789.0987654321)

		json.number = nil
		XCTAssertEqual(json.object, nil)
		XCTAssertTrue(json.number == nil)

		json.numberValue = 2.9876
		XCTAssertEqual(json.number!, 2.9876)
	}

	func testDouble() {
		var json: JSON = 9_876_543_210.123456789
		XCTAssertEqual(json.double, 9_876_543_210.123456789)
		XCTAssertEqual(json.description, "9876543210.123457")

		json.double = 2.8765432
		XCTAssertEqual(json.double!, 2.8765432)

		json.double = 89.0987654
		XCTAssertEqual(json.double!, 89.0987654)

		json.double = nil
		XCTAssertEqual(json, .null)
	}

	func testFloat() {
		var json: JSON = 54321.12345
		XCTAssertEqual(json.number, 54321.12345)
		XCTAssertEqual(json.description, "54321.12345")

		json.double = 23231.65
		XCTAssertTrue(json.double == 23231.65)

		json.double = -98766.23
		XCTAssertEqual(json.double, -98766.23)
	}

	func testInt() {
		var json: JSON = 123_456_789
		XCTAssertEqual(json.int, 123_456_789)
		XCTAssertEqual(json.number, 123_456_789)
		XCTAssertEqual(json.description, "123456789")

		json.int = nil
		XCTAssertEqual(json, .null)

		json.int = 76543
		XCTAssertEqual(json.int!, 76543)
		XCTAssertEqual(json.numberValue, 76543)

		json.int = 98_765_421
		XCTAssertEqual(json.int!, 98_765_421)
	}
}
