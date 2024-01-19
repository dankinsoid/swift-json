import SwiftJSON
import XCTest

class SequenceTypeTests: XCTestCase {

	func testJSONFile() {
		if let file = Bundle(for: BaseTests.self).path(forResource: "Tests", ofType: "json") {
			let testData = try? Data(contentsOf: URL(fileURLWithPath: file))
			guard let json = try? JSON(from: testData!) else {
				XCTFail("Unable to parse the data")
				return
			}
			XCTAssertEqual(json.count, 10)
		} else {
			XCTFail("Can't find the test JSON file")
		}
	}

	func testArrayAllNumber() {
		let json: JSON = [1, 2.0, 3.3, 123_456_789, 987_654_321.123456789]
		XCTAssertEqual(json.count, 5)

		var index = 0
		var array: [Decimal?] = []
		for value in json {
			XCTAssertEqual(value, json[index])
			array.append(value.number)
			index += 1
		}
		XCTAssertEqual(index, 5)
		XCTAssertEqual(array, [1, 2.0, 3.3, 123_456_789, 987_654_321.123456789])
	}

	func testArrayAllBool() {
		let json: JSON = [true, false, false, true, true]
		XCTAssertEqual(json.count, 5)

		var index = 0
		var array: [Bool?] = []
		for sub in json {
			XCTAssertEqual(sub, json[index])
			array.append(sub.bool)
			index += 1
		}
		XCTAssertEqual(index, 5)
		XCTAssertEqual(array, [true, false, false, true, true])
	}

	func testArrayAllString() {
		let json: JSON = ["aoo", "bpp", "zoo"]
		XCTAssertEqual(json.count, 3)

		var index = 0
		var array: [String?] = []
		for sub in json {
			XCTAssertEqual(sub, json[index])
			array.append(sub.string)
			index += 1
		}
		XCTAssertEqual(index, 3)
		XCTAssertEqual(array, ["aoo", "bpp", "zoo"])
	}

	func testArrayWithNull() {
		let json: JSON = ["aoo", "bpp", .null, "zoo"]
		XCTAssertEqual(json.count, 4)

		var index = 0
		var array: [Any?] = []
		for sub in json {
			XCTAssertEqual(sub, json[index])
			array.append(sub.value)
			index += 1
		}
		XCTAssertEqual(index, 4)
		XCTAssertEqual(array[0] as? String, "aoo")
		XCTAssertTrue(array[2] == nil)
	}

	func testArrayAllDictionary() {
		let json: JSON = [["1": 1, "2": 2], ["a": "A", "b": "B"], ["null": .null]]
		XCTAssertEqual(json.count, 3)

		var index = 0
		var array: [Any?] = []
		for sub in json {
			XCTAssertEqual(sub, json[index])
			array.append(sub.extract())
			index += 1
		}
		XCTAssertEqual(index, 3)
		XCTAssertEqual((array[0] as! [String: Int])["1"]!, 1)
		XCTAssertEqual((array[0] as! [String: Int])["2"]!, 2)
		XCTAssertEqual((array[1] as! [String: String])["a"]!, "A")
		XCTAssertEqual((array[1] as! [String: String])["b"]!, "B")
		XCTAssertTrue((array[2] as! [String: Any])["null"] == nil)
	}

	func testDictionaryAllNumber() {
		let json: JSON = ["double": 1.11111, "int": 987_654_321]
		XCTAssertEqual(json.count, 2)

		var index = 0
		var dictionary: [String: Decimal] = [:]
		for sub in json {
			dictionary[sub.object?.first?.key ?? ""] = sub.object?.first?.value.number
			index += 1
		}

		XCTAssertEqual(index, 2)
		XCTAssertEqual(dictionary["double"], 1.11111)
		XCTAssertEqual(dictionary["int"], 987_654_321)
	}

	func testDictionaryAllBool() {
		let json: JSON = ["t": true, "f": false, "false": false, "tr": true, "true": true]
		XCTAssertEqual(json.count, 5)

		var index = 0
		var dictionary: [String: Bool] = [:]
		for sub in json {
			dictionary[sub.object?.first?.key ?? ""] = sub.object?.first?.value.bool
			index += 1
		}

		XCTAssertEqual(index, 5)
		XCTAssertEqual(dictionary["t"]! as Bool, true)
		XCTAssertEqual(dictionary["false"]! as Bool, false)
	}

	func testDictionaryAllString() {
		let json: JSON = ["a": "aoo", "bb": "bpp", "z": "zoo"]
		XCTAssertEqual(json.count, 3)

		var index = 0
		var dictionary: [String: String] = [:]
		for sub in json {
			dictionary[sub.object?.first?.key ?? ""] = sub.object?.first?.value.string
			index += 1
		}

		XCTAssertEqual(index, 3)
		XCTAssertEqual(dictionary["a"], "aoo")
		XCTAssertEqual(dictionary["bb"], "bpp")
	}

	func testDictionaryWithNull() {
		let json: JSON = ["a": "aoo", "bb": "bpp", "null": .null, "z": "zoo"]
		XCTAssertEqual(json.count, 4)

		var index = 0
		var dictionary: [String: Any?] = [:]
		for sub in json {
			dictionary[sub.object?.first?.key ?? ""] = sub.object?.first?.value
			index += 1
		}

		XCTAssertEqual(index, 4)
		XCTAssertEqual(dictionary["a"]! as? String, "aoo")
		XCTAssertEqual(dictionary["bb"]! as? String, "bpp")
		XCTAssertTrue(dictionary["null"] == nil)
	}

	func testDictionaryAllArray() {
		let json: JSON = ["Number": [1, 2.123456, 123_456_789], "String": ["aa", "bbb", "cccc"], "Mix": [true, "766", .null, 655_231.9823]]

		XCTAssertEqual(json.count, 3)

		var index = 0
		var dictionary: [String: Any?] = [:]
		for sub in json {
			dictionary[sub.object?.first?.key ?? ""] = sub.object?.first?.value.extract()
			index += 1
		}

		XCTAssertEqual(index, 3)
		XCTAssertEqual((dictionary["Number"] as! [Any?])[0] as? Int, 1)
		XCTAssertEqual((dictionary["Number"] as! [Any?])[1] as? Double, 2.123456)
		XCTAssertEqual((dictionary["String"] as! [Any?])[0] as? String, "aa")
		XCTAssertEqual((dictionary["Mix"] as! [Any?])[0] as? Bool, true)
		XCTAssertEqual((dictionary["Mix"] as! [Any?])[1] as? String, "766")
		XCTAssertTrue((dictionary["Mix"] as! [Any?])[2] == nil)
		XCTAssertEqual((dictionary["Mix"] as! [Any?])[3] as? Double, 655_231.9823)
	}

	func testDictionaryIteratingPerformance() {
		var json: JSON = [:]
		for i in 1 ... 1000 {
			json[String(i)] = "hello"
		}
		measure {
			for value in json {
				print(value)
			}
		}
	}
}
