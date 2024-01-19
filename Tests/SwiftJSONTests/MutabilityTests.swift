import SwiftJSON
import XCTest

class MutabilityTests: XCTestCase {

	func testDictionaryMutability() {
		let dictionary: [String: Any] = [
			"string": "STRING",
			"number": 9823.212,
			"bool": true,
			"empty": ["nothing"],
			"foo": ["bar": ["1"]],
			"bar": ["foo": ["1": "a"]],
		]

		var json = JSON(dictionary).orNull
		XCTAssertEqual(json["string"], "STRING")
		XCTAssertEqual(json["number"], 9823.212)
		XCTAssertEqual(json["bool"], true)
		XCTAssertEqual(json["empty"], ["nothing"])

		json["string"] = "muted"
		XCTAssertEqual(json["string"], "muted")

		json["number"] = 9999.0
		XCTAssertEqual(json["number"], 9999.0)

		json["bool"] = false
		XCTAssertEqual(json["bool"], false)

		json["empty"] = []
		XCTAssertEqual(json["empty"], [])

		json["new"] = JSON(["foo": "bar"])
		XCTAssertEqual(json["new"], ["foo": "bar"])

		json.foo.bar = JSON([]).orNull
		XCTAssertEqual(json.foo.bar, [])

		json.bar.foo = JSON(["2": "b"]).orNull
		XCTAssertEqual(json.bar.foo, ["2": "b"])
	}

	func testArrayMutability() {
		let array: [Any] = ["1", "2", 3, true, []]

		var json = JSON(array).orNull
		XCTAssertEqual(json[0], "1")
		XCTAssertEqual(json[1], "2")
		XCTAssertEqual(json[2], 3)
		XCTAssertEqual(json[3], true)
		XCTAssertEqual(json[4], [])

		json[0] = false
		XCTAssertEqual(json[0], false)

		json[1] = 2
		XCTAssertEqual(json[1], 2)

		json[2] = "3"
		XCTAssertEqual(json[2], "3")

		json[3] = [:]
		XCTAssertEqual(json[3], [:])

		json[4] = [1, 2]
		XCTAssertEqual(json[4], [1, 2])
	}

	func testValueMutability() {
		var intArray = JSON([0, 1, 2]).orNull
		intArray[0] = JSON(55)
		XCTAssertEqual(intArray[0], 55)
		XCTAssertEqual(intArray[0]?.int, 55)

		var dictionary = JSON(["foo": "bar"]).orNull
		dictionary["foo"] = JSON("foo")
		XCTAssertEqual(dictionary["foo"], "foo")
		XCTAssertEqual(dictionary["foo"]?.string, "foo")

		var number = JSON(1)
		number = JSON("111")
		XCTAssertEqual(number, "111")
		XCTAssertEqual(number.int, 111)
		XCTAssertEqual(number.stringValue, "111")

		var boolean = JSON(true)
		boolean = JSON(false)
		XCTAssertEqual(boolean, false)
		XCTAssertEqual(boolean.boolValue, false)
	}

	func testArrayRemovability() {
		let array = ["Test", "Test2", "Test3"]
		var json = JSON(array).orNull

		json.array?.removeFirst()
		XCTAssertEqual(false, json.array?.isEmpty)
		XCTAssertEqual(json.array, ["Test2", "Test3"])

		json.array?.removeLast()
		XCTAssertEqual(false, json.array?.isEmpty)
		XCTAssertEqual(json.array, ["Test2"])

		json.array?.removeAll()
		XCTAssertEqual(true, json.array?.isEmpty)
		XCTAssertEqual(JSON([]), json)
	}

	func testDictionaryRemovability() {
		let dictionary: [String: Any] = ["key1": "Value1", "key2": 2, "key3": true]
		var json = JSON(dictionary).orNull

		json.object?.removeValue(forKey: "key1")
		XCTAssertEqual(false, json.object?.isEmpty)
		XCTAssertEqual(json.object, ["key2": 2, "key3": true])

		json.object?.removeValue(forKey: "key3")
		XCTAssertEqual(false, json.object?.isEmpty)
		XCTAssertEqual(json.object, ["key2": 2])

		json.object?.removeAll()
		XCTAssertEqual(true, json.object?.isEmpty)
		XCTAssertEqual(json.object, [:])
	}
}
