import SwiftJSON
import XCTest

class ComparableTests: XCTestCase {

	func testNumberEqual() {
		let jsonL1: JSON = 1_234_567_890.876623
		let jsonR1 = JSON(1_234_567_890.876623)
		XCTAssertEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 == 1_234_567_890.876623)

		let jsonL2: JSON = 987_654_321
		let jsonR2 = JSON(987_654_321)
		XCTAssertEqual(jsonL2, jsonR2)
		XCTAssertTrue(jsonR2 == 987_654_321)

		let jsonL3 = JSON(87_654_321.12345678)
		let jsonR3 = JSON(87_654_321.12345678)
		XCTAssertEqual(jsonL3, jsonR3)
		XCTAssertTrue(jsonR3 == 87_654_321.12345678)
	}

	func testNumberNotEqual() {
		let jsonL1: JSON = 1_234_567_890.876623
		let jsonR1 = JSON(123.123)
		XCTAssertNotEqual(jsonL1, jsonR1)
		XCTAssertFalse(jsonL1 == 34343)

		let jsonL2: JSON = 8773
		let jsonR2 = JSON(123.23)
		XCTAssertNotEqual(jsonL2, jsonR2)
		XCTAssertFalse(jsonR1 == 454_352)

		let jsonL3 = JSON(87621.12345678)
		let jsonR3 = JSON(87_654_321.45678)
		XCTAssertNotEqual(jsonL3, jsonR3)
		XCTAssertFalse(jsonL3 == 4545.232)
	}

	func testNumberGreaterThanOrEqual() {
		let jsonL1: JSON = 1_234_567_890.876623
		let jsonR1 = JSON(123.123)
		XCTAssertGreaterThanOrEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 >= -37434)

		let jsonL2: JSON = 8773
		let jsonR2 = JSON(-87343)
		XCTAssertGreaterThanOrEqual(jsonL2, jsonR2)
		XCTAssertTrue(jsonR2 >= -988_343)

		let jsonL3 = JSON(87621.12345678).orNull
		let jsonR3 = JSON(87621.12345678).orNull
		XCTAssertGreaterThanOrEqual(jsonL3, jsonR3)
		XCTAssertTrue(jsonR3 >= 0.3232)
	}

	func testNumberLessThanOrEqual() {
		let jsonL1: JSON = 1_234_567_890.876623
		let jsonR1 = JSON(123.123)
		XCTAssertLessThanOrEqual(jsonR1, jsonL1)
		XCTAssertFalse(jsonR1 >= 83_487_343.3493)

		let jsonL2: JSON = 8773
		let jsonR2 = JSON(-123.23)
		XCTAssertLessThanOrEqual(jsonR2, jsonL2)
		XCTAssertFalse(jsonR2 >= 9_348_343)

		let jsonL3 = JSON(87621.12345678)
		let jsonR3 = JSON(87621.12345678)
		XCTAssertLessThanOrEqual(jsonR3, jsonL3)
		XCTAssertTrue(jsonR3 >= 87621.12345678)
	}

	func testNumberGreaterThan() {
		let jsonL1: JSON = 1_234_567_890.876623
		let jsonR1 = JSON(123.123)
		XCTAssertGreaterThan(jsonL1, jsonR1)
		XCTAssertFalse(jsonR1 > 192_388_843.0988)

		let jsonL2: JSON = 8773
		let jsonR2 = JSON(123.23)
		XCTAssertGreaterThan(jsonL2, jsonR2)
		XCTAssertFalse(jsonR2 > 877_434)

		let jsonL3 = JSON(87621.12345678)
		let jsonR3 = JSON(87621.1234567)
		XCTAssertGreaterThan(jsonL3, jsonR3)
		XCTAssertFalse(jsonR3 < -7799)
	}

	func testNumberLessThan() {
		let jsonL1: JSON = 1_234_567_890.876623
		let jsonR1 = JSON(123.123)
		XCTAssertLessThan(jsonR1, jsonL1)
		XCTAssertTrue(jsonR1 < 192_388_843.0988)

		let jsonL2: JSON = 8773
		let jsonR2 = JSON(123.23)
		XCTAssertLessThan(jsonR2, jsonL2)
		XCTAssertTrue(jsonR2 < 877_434)

		let jsonL3 = JSON(87621.12345678)
		let jsonR3 = JSON(87621.1234567)
		XCTAssertLessThan(jsonR3, jsonL3)
		XCTAssertTrue(jsonR3 > -7799)
	}

	func testBoolEqual() {
		let jsonL1: JSON = true
		let jsonR1 = JSON(true)
		XCTAssertEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 == true)

		let jsonL2: JSON = false
		let jsonR2 = JSON(false)
		XCTAssertEqual(jsonL2, jsonR2)
		XCTAssertTrue(jsonL2 == false)
	}

	func testBoolNotEqual() {
		let jsonL1: JSON = true
		let jsonR1 = JSON(false)
		XCTAssertNotEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 != false)

		let jsonL2: JSON = false
		let jsonR2 = JSON(true)
		XCTAssertNotEqual(jsonL2, jsonR2)
		XCTAssertTrue(jsonL2 != true)
	}

	func testBoolGreaterThanOrEqual() {
		let jsonL1: JSON = true
		let jsonR1 = JSON(true)
		XCTAssertGreaterThanOrEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 >= true)

		let jsonL2: JSON = false
		let jsonR2 = JSON(false)
		XCTAssertGreaterThanOrEqual(jsonL2, jsonR2)
		XCTAssertFalse(jsonL2 >= true)
	}

	func testBoolLessThanOrEqual() {
		let jsonL1: JSON = true
		let jsonR1 = JSON(true)
		XCTAssertLessThanOrEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonR1 >= true)

		let jsonL2: JSON = false
		let jsonR2 = JSON(false)
		XCTAssertLessThanOrEqual(jsonL2, jsonR2)
		XCTAssertFalse(jsonL2 <= true)
	}

	func testBoolGreaterThan() {
		let jsonL1: JSON = true
		let jsonR1 = JSON(true)
		XCTAssertFalse(jsonL1 > jsonR1)
		XCTAssertFalse(jsonL1 > true)
		XCTAssertFalse(jsonR1 > false)

		let jsonL2: JSON = false
		let jsonR2 = JSON(false)
		XCTAssertFalse(jsonL2 > jsonR2)
		XCTAssertFalse(jsonL2 > false)
		XCTAssertFalse(jsonR2 > true)

		let jsonL3: JSON = true
		let jsonR3 = JSON(false)
		XCTAssertFalse(jsonL3 > jsonR3)
		XCTAssertFalse(jsonL3 > false)
		XCTAssertFalse(jsonR3 > true)

		let jsonL4: JSON = false
		let jsonR4 = JSON(true)
		XCTAssertFalse(jsonL4 > jsonR4)
		XCTAssertFalse(jsonL4 > false)
		XCTAssertFalse(jsonR4 > true)
	}

	func testBoolLessThan() {
		let jsonL1: JSON = true
		let jsonR1 = JSON(true)
		XCTAssertFalse(jsonL1 < jsonR1)
		XCTAssertFalse(jsonL1 < true)
		XCTAssertFalse(jsonR1 < false)

		let jsonL2: JSON = false
		let jsonR2 = JSON(false)
		XCTAssertFalse(jsonL2 < jsonR2)
		XCTAssertFalse(jsonL2 < false)
		XCTAssertFalse(jsonR2 < true)

		let jsonL3: JSON = true
		let jsonR3 = JSON(false)
		XCTAssertFalse(jsonL3 < jsonR3)
		XCTAssertFalse(jsonL3 < false)
		XCTAssertFalse(jsonR3 < true)

		let jsonL4: JSON = false
		let jsonR4 = JSON(true)
		XCTAssertFalse(jsonL4 < jsonR4)
		XCTAssertFalse(jsonL4 < false)
		XCTAssertFalse(jsonR4 > true)
	}

	func testStringEqual() {
		let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
		let jsonR1 = JSON("abcdefg 123456789 !@#$%^&*()")

		XCTAssertEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 == "abcdefg 123456789 !@#$%^&*()")
	}

	func testStringNotEqual() {
		let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
		let jsonR1 = JSON("-=[]\\\"987654321")

		XCTAssertNotEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 != "not equal")
	}

	func testStringGreaterThanOrEqual() {
		let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
		let jsonR1 = JSON("abcdefg 123456789 !@#$%^&*()")

		XCTAssertGreaterThanOrEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 >= "abcdefg 123456789 !@#$%^&*()")

		let jsonL2: JSON = "z-+{}:"
		let jsonR2 = JSON("a<>?:")
		XCTAssertGreaterThanOrEqual(jsonL2, jsonR2)
		XCTAssertTrue(jsonL2 >= "mnbvcxz")
	}

	func testStringLessThanOrEqual() {
		let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
		let jsonR1 = JSON("abcdefg 123456789 !@#$%^&*()")

		XCTAssertLessThanOrEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 <= "abcdefg 123456789 !@#$%^&*()")

		let jsonL2: JSON = "z-+{}:"
		let jsonR2 = JSON("a<>?:")
		XCTAssertLessThanOrEqual(jsonR2, jsonL2)
		XCTAssertTrue(jsonL2 >= "mnbvcxz")
	}

	func testStringGreaterThan() {
		let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
		let jsonR1 = JSON("abcdefg 123456789 !@#$%^&*()")

		XCTAssertFalse(jsonL1 > jsonR1)
		XCTAssertFalse(jsonL1 > "abcdefg 123456789 !@#$%^&*()")

		let jsonL2: JSON = "z-+{}:"
		let jsonR2 = JSON("a<>?:")
		XCTAssertGreaterThan(jsonL2, jsonR2)
		XCTAssertFalse(jsonL2 < "87663434")
	}

	func testStringLessThan() {
		let jsonL1: JSON = "abcdefg 123456789 !@#$%^&*()"
		let jsonR1 = JSON("abcdefg 123456789 !@#$%^&*()")

		XCTAssertFalse(jsonL1 < jsonR1)
		XCTAssertFalse(jsonL1 < "abcdefg 123456789 !@#$%^&*()")

		let jsonL2: JSON = "98774"
		let jsonR2 = JSON("123456")
		XCTAssertLessThan(jsonR2, jsonL2)
		XCTAssertFalse(jsonL2 < "09")
	}

	func testArray() {
		let jsonL1: JSON = [1, 2, "4", 5, "6"]
		let jsonR1 = JSON([1, 2, "4", 5, "6"]).orNull
		XCTAssertEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 == [1, 2, "4", 5, "6"])
		XCTAssertTrue(jsonL1 != ["abcd", "efg"])
		XCTAssertTrue(jsonL1 >= jsonR1)
		XCTAssertTrue(jsonL1 <= jsonR1)
		XCTAssertFalse(jsonL1 > ["abcd", ""])
		XCTAssertFalse(jsonR1 < [])
		XCTAssertFalse(jsonL1 >= [:])
	}

	func testDictionary() {
		let jsonL1: JSON = ["2": 2, "name": "Jack", "List": ["a", 1.09, .null]]
		let jsonR1 = JSON(["2": 2, "name": "Jack", "List": ["a", 1.09, nil]]).orNull

		XCTAssertEqual(jsonL1, jsonR1)
		XCTAssertTrue(jsonL1 != ["1": 2, "Hello": "World", "Koo": "Foo"])
		XCTAssertTrue(jsonL1 >= jsonR1)
		XCTAssertTrue(jsonL1 <= jsonR1)
		XCTAssertFalse(jsonL1 >= [:])
		XCTAssertFalse(jsonR1 <= ["999": "aaaa"])
		XCTAssertFalse(jsonL1 > [")(*&^": 1_234_567])
		XCTAssertFalse(jsonR1 < ["MNHH": "JUYTR"])
	}
}
