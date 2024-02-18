import SwiftJSON
import XCTest

class SubscriptTests: XCTestCase {

	func testArrayAllNumber() {
		var json: JSON = [1, 2.0, 3.3, 123_456_789, 987_654_321.123456789]
		XCTAssertTrue(json == [1, 2.0, 3.3, 123_456_789, 987_654_321.123456789])
		XCTAssertTrue(json[0] == 1)
		XCTAssertEqual(json[1]?.double, 2.0)
		XCTAssertTrue(json[2]?.double == 3.3)
		XCTAssertEqual(json[3]?.int, 123_456_789)
		XCTAssertEqual(json[4]?.double ?? 0, 987_654_321.123456789, accuracy: 0.0001)

		json[0] = 1.9
		json[1] = 2.899
		json[2] = 3.567
		json[3] = 0.999
		json[4] = 98732

		XCTAssertTrue(json[0] == 1.9)
		XCTAssertEqual(json[1]?.double ?? 0, 2.899, accuracy: 0.0001)
		XCTAssertTrue(json[2] == 3.567)
		XCTAssertTrue(json[4]?.int == 98732)
	}

	func testArrayAllBool() {
		var json: JSON = [true, false, false, true, true]
		XCTAssertTrue(json == [true, false, false, true, true])
		XCTAssertTrue(json[0] == true)
		XCTAssertTrue(json[1] == false)
		XCTAssertTrue(json[2] == false)
		XCTAssertTrue(json[3] == true)
		XCTAssertTrue(json[4] == true)

		json[0] = false
		json[4] = true
		XCTAssertTrue(json[0] == false)
		XCTAssertTrue(json[4] == true)
	}

	func testArrayAllString() {
		var json: JSON = ["aoo", "bpp", "zoo"]
		XCTAssertTrue(json == ["aoo", "bpp", "zoo"])
		XCTAssertTrue(json[0] == "aoo")
		XCTAssertTrue(json[1] == "bpp")
		XCTAssertTrue(json[2] == "zoo")

		json[1] = "update"
		XCTAssertTrue(json[0] == "aoo")
		XCTAssertTrue(json[1] == "update")
		XCTAssertTrue(json[2] == "zoo")
	}

	func testArrayWithNull() {
		var json: JSON = ["aoo", "bpp", .null, "zoo"]
		XCTAssertTrue(json[0] == "aoo")
		XCTAssertTrue(json[1] == "bpp")
		XCTAssertNil(json[2]?.string)
		XCTAssertEqual(json[2]?.is(.null), true)
		XCTAssertTrue(json[3] == "zoo")

		json[2] = "update"
		json[3] = .null
		XCTAssertTrue(json[0] == "aoo")
		XCTAssertTrue(json[1] == "bpp")
		XCTAssertTrue(json[2] == "update")
		XCTAssertNil(json[3]?.string)
		XCTAssertEqual(json[3]?.is(.null), true)
	}

	func testArrayAllDictionary() {
		let json: JSON = [["1": 1, "2": 2], ["a": "A", "b": "B"], ["null": .null]]
		XCTAssertTrue(json[0] == ["1": 1, "2": 2])
		XCTAssertEqual(json[1]?.object, ["a": "A", "b": "B"])
		XCTAssertEqual(json[2], ["null": .null])
		XCTAssertTrue(json[0]?["1"] == 1)
		XCTAssertTrue(json[0]?["2"] == 2)
		XCTAssertEqual(json[1]?["a"], "A")
		XCTAssertEqual(json[1]?["b"], JSON("B"))
		XCTAssertEqual(json[2]?["null"]?.is(.null), true)
		XCTAssertEqual(json[2]?["null"]?.is(.null), true)
	}

	func testDictionaryAllNumber() {
		var json: JSON = ["double": 1.11111, "int": 987_654_321]
		XCTAssertEqual(json["double"]?.double ?? 0, 1.11111, accuracy: 0.0001)
		XCTAssertTrue(json["int"] == 987_654_321)

		json["double"] = 2.2222
		json["int"] = 123_456_789
		json["add"] = 7890
		XCTAssertTrue(json["double"] == 2.2222)
		XCTAssertEqual(json["int"]?.double ?? 0, 123_456_789.0, accuracy: 0.0001)
		XCTAssertEqual(json["add"]?.int, 7890)
	}

	func testDictionaryAllBool() {
		var json: JSON = ["t": true, "f": false, "false": false, "tr": true, "true": true, "yes": true, "1": true]
		XCTAssertTrue(json["1"] == true)
		XCTAssertTrue(json["yes"] == true)
		XCTAssertTrue(json["t"] == true)
		XCTAssertTrue(json["f"] == false)
		XCTAssertTrue(json["false"] == false)
		XCTAssertTrue(json["tr"] == true)
		XCTAssertTrue(json["true"] == true)

		json["f"] = true
		json["tr"] = false
		XCTAssertTrue(json["f"] == true)
		XCTAssertTrue(json["tr"] == JSON(false))
	}

	func testDictionaryAllString() {
		var json: JSON = ["a": "aoo", "bb": "bpp", "z": "zoo"]
		XCTAssertTrue(json["a"] == "aoo")
		XCTAssertEqual(json["bb"], "bpp")
		XCTAssertTrue(json["z"] == "zoo")

		json["bb"] = "update"
		XCTAssertTrue(json["a"] == "aoo")
		XCTAssertTrue(json["bb"] == "update")
		XCTAssertTrue(json["z"] == "zoo")
	}

	func testDictionaryWithNull() {
		var json: JSON = ["a": "aoo", "bb": "bpp", "null": .null, "z": "zoo"]
		XCTAssertTrue(json["a"] == "aoo")
		XCTAssertEqual(json["bb"], "bpp")
		XCTAssertEqual(json["null"], .null)
		XCTAssertTrue(json["z"] == "zoo")

		json["null"] = "update"
		XCTAssertTrue(json["a"] == "aoo")
		XCTAssertTrue(json["null"] == "update")
		XCTAssertTrue(json["z"] == "zoo")
	}

	func testDictionaryAllArray() {
		// Swift bug: [1, 2.01,3.09] is convert to [1, 2, 3] (Array<Int>)
		let json: JSON = [[1, 2.123456, 123_456_789], ["aa", "bbb", "cccc"], [true, "766", .null, 655_231.9823]]
		XCTAssertTrue(json[0] == [1, 2.123456, 123_456_789])
		XCTAssertEqual(json[0]?[1]?.double, 2.123456)
		XCTAssertTrue(json[0]?[2] == 123_456_789)
		XCTAssertTrue(json[1]?[0] == "aa")
		XCTAssertTrue(json[1] == ["aa", "bbb", "cccc"])
		XCTAssertTrue(json[2]?[0] == true)
		XCTAssertTrue(json[2]?[1] == "766")
		XCTAssertTrue(json[2]?[1] == "766")
		XCTAssertEqual(json[2]?[2], .null)
		XCTAssertEqual(json[2]?[2], .null)
		XCTAssertEqual(json[2]?[3], JSON(655_231.9823))
		XCTAssertEqual(json[2]?[3], JSON(655_231.9823))
		XCTAssertEqual(json[2]?[3], JSON(655_231.9823))
	}

	func testMultilevelGetter() {
		let json: JSON = [[[[["one": 1]]]]]
		XCTAssertEqual(json[[0, 0, 0, 0, "one"]]?.int, 1)
		XCTAssertEqual(json[0, 0, 0, 0, "one"]?.int, 1)
		XCTAssertEqual(json[0]?[0]?[0]?[0]?["one"]?.int, 1)
	}

	func testMultilevelSetter1() {
		var json: JSON = [[[[["num": 1]]]]]
		json[0, 0, 0, 0, "num"] = 2
		XCTAssertEqual(json[[0, 0, 0, 0, "num"]]?.int, 2)
		json[0, 0, 0, 0, "num"] = .null
		XCTAssertTrue(json[0, 0, 0, 0, "num", or: 0].is(.null))
		json[0, 0, 0, 0, "num"] = 100.009
		XCTAssertEqual(json[0]?[0]?[0]?[0]?["num"]?.double ?? 0, 100.009, accuracy: 0.0001)
		json[[0, 0, 0, 0]] = ["name": "Jack"]
		XCTAssertEqual(json[0, 0, 0, 0, "name"]?.string, "Jack")
		XCTAssertEqual(json[0]?[0]?[0]?[0]?["name"]?.string, "Jack")
		XCTAssertEqual(json[[0, 0, 0, 0, "name"]]?.string, "Jack")
		json[[0, 0, 0, 0, "name"]]?.string = "Mike"
		XCTAssertEqual(json[0, 0, 0, 0, "name"]?.string, "Mike")
		let path: [JSONKeyType] = [0, 0, 0, 0, "name"]
		json[path] = "Jim"
		XCTAssertEqual(json[path]?.string, "Jim")
	}

	func testMultilevelSetter2() {
		var json: JSON = ["user": ["id": 987_654, "info": ["name": "jack", "email": "jack@gmail.com"], "feeds": [98833, 23443, 213_239, 23232]]]
		json["user", "info", "name"] = "jim"
		XCTAssertEqual(json["user", "id"], 987_654)
		XCTAssertEqual(json["user", "info", "name"], "jim")
		XCTAssertEqual(json["user", "info", "email"], "jack@gmail.com")
		XCTAssertEqual(json["user", "feeds"], [98833, 23443, 213_239, 23232])
		json["user", "info", "email"] = "jim@hotmail.com"
		XCTAssertEqual(json["user", "id"], 987_654)
		XCTAssertEqual(json["user", "info", "name"], "jim")
		XCTAssertEqual(json["user", "info", "email"], "jim@hotmail.com")
		XCTAssertEqual(json["user", "feeds"], [98833, 23443, 213_239, 23232])
		json["user", "info"] = ["name": "tom", "email": "tom@qq.com"]
		XCTAssertEqual(json["user", "id"], 987_654)
		XCTAssertEqual(json["user", "info", "name"], "tom")
		XCTAssertEqual(json["user", "info", "email"], "tom@qq.com")
		XCTAssertEqual(json["user", "feeds"], [98833, 23443, 213_239, 23232])
		json["user", "feeds"] = [77323, 2313, 4545, 323]
		XCTAssertEqual(json["user", "id"], 987_654)
		XCTAssertEqual(json["user", "info", "name"], "tom")
		XCTAssertEqual(json["user", "info", "email"], "tom@qq.com")
		XCTAssertEqual(json["user", "feeds"], [77323, 2313, 4545, 323])
	}
}
