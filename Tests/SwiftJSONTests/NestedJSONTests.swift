import SwiftJSON
import XCTest

class NestedJSONTests: XCTestCase {
	let family: JSON = [
		"names": [
			"Brooke Abigail Matos",
			"Rowan Danger Matos",
		],
		"motto": "Hey, I don't know about you, but I'm feeling twenty-two! So, release the KrakenDev!",
	]

	func testTopLevelNestedJSON() {
		let nestedJSON: JSON = [
			"family": family,
		]
		XCTAssertFalse(nestedJSON.data.isEmpty)
	}

	func testDeeplyNestedJSON() {
		let nestedFamily: JSON = [
			"count": 1,
			"families": [
				[
					"isACoolFamily": true,
					"family": [
						"hello": family,
					],
				],
			],
		]
		XCTAssertFalse(nestedFamily.data.isEmpty)
	}

	func testArrayJSON() {
		let arr: [JSON] = ["a", 1, ["b", 2]]
		let json = JSON(arr).orNull
		XCTAssertEqual(json[0]?.string, "a")
		XCTAssertEqual(json[2]?[1]?.int, 2)
	}

	func testDictionaryJSON() {
		let json: JSON = ["a": "1", "b": [1, 2, "3"], "c": ["aa": "11", "bb": 22]]
		XCTAssertEqual(json["a"]?.string, "1")
		XCTAssertEqual(json["b"]?.array, [1, 2, "3"])
		XCTAssertEqual(json["c"]?["aa"]?.string, "11")
	}

	func testNestedJSON() {
		let inner: JSON = [
			"some_field": "1" + "2" as JSON,
		]
		let json: JSON = [
			"outer_field": "1" + "2" as JSON,
			"inner_json": inner,
		]
		XCTAssertEqual(json["inner_json"], ["some_field": "12"])

		let foo: JSON = "foo"
		let json2: JSON = [
			"outer_field": foo,
			"inner_json": inner,
		]
		XCTAssertEqual(json2["inner_json"]?.extract() as? [String: String], ["some_field": "12"])
	}
}
