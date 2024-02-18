import SwiftJSON
import XCTest

class NumberTests: XCTestCase {

	func testNumber() {
		// getter
		var json = JSON(9_876_543_210.123456789)
		XCTAssertEqual(json.number, 9_876_543_210.123456789)
		XCTAssertEqual(json.description, "9876543210.123456512")

		json.string = "1000000000000000000000000000.1"
		XCTAssertEqual(json.description, "\"1000000000000000000000000000.1\"")

		json.number = 1e+27
		XCTAssertEqual(json.description, "1000000000000000000000000000")

		json.number = Decimal(string: "1e+27")
		XCTAssertEqual(json.description, "1000000000000000000000000000")
		// setter
		json.number = 123_456_789.0987654321
		XCTAssertEqual(json.number, 123_456_789.0987654321)

		json.number = nil
		XCTAssertEqual(json.object, nil)
		XCTAssertTrue(json.number == nil)
	}

	func testDouble() {
		var json: JSON = 9_876_543_210.123456789
		XCTAssertEqual(json.double, 9_876_543_210.123456789)
		XCTAssertEqual(json.description, "9876543210.123456512")

		json.double = 2.8765432
		XCTAssertEqual(json.double!, 2.8765432, accuracy: 0.0000001)

		json.double = 89.0987654
		XCTAssertEqual(json.double!, 89.0987654, accuracy: 0.0000001)

		json.double = nil
		XCTAssertEqual(json, .null)
	}

	func testFloat() {
		var json: JSON = 54321.12345
		XCTAssertEqual(json.number, 54321.12345)
		XCTAssertEqual(json.description, "54321.12344999999488")

		json.double = 23231.65
		XCTAssertTrue(json.double == 23231.65)

		json.double = -98766.23
		XCTAssertEqual(json.double, -98766.23000000001)
	}

	func testInt() {
		var json: JSON = 123_456_789
		XCTAssertEqual(json.int, 123_456_789)
		XCTAssertEqual(json.number, 123_456_789)
		XCTAssertEqual(json.description, "123456789")

		json.int = nil
		XCTAssertEqual(json, .null)

		json.int = 76543
		XCTAssertEqual(json.int, 76543)
		XCTAssertEqual(json.number, 76543)

		json.int = 98_765_421
		XCTAssertEqual(json.int, 98_765_421)
	}
}
