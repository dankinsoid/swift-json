import SwiftJSON
import XCTest

class StringTests: XCTestCase {

	func testString() {
		// getter
		var json = JSON("abcdefg hijklmn;opqrst.?+_()")
		XCTAssertEqual(json.string, "abcdefg hijklmn;opqrst.?+_()")

		json.string = "12345?67890.@#"
		XCTAssertEqual(json.string, "12345?67890.@#")
	}

	func testBool() {
		let json: JSON = "true"
		XCTAssertEqual(json.bool, true)
	}

	func testBoolWithY() {
		let json: JSON = "Y"
		XCTAssertEqual(json.bool, true)
	}

	func testBoolWithT() {
		let json: JSON = "T"
		XCTAssertEqual(json.bool, true)
	}

	func testBoolWithYes() {
		let json: JSON = "Yes"
		XCTAssertEqual(json.bool, true)
	}

	func testBoolWith1() {
		let json: JSON = "1"
		XCTAssertEqual(json.bool, true)
	}
}
