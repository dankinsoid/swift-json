import SwiftJSON
import XCTest

class CodableTests: XCTestCase {

	func testEncodeNull() throws {
		var json = JSON([()])
		_ = try JSONEncoder().encode(json)
		json = JSON([nil])
		_ = try JSONEncoder().encode(json)
		let dictionary: [String: Any?] = ["key": nil]
		json = JSON(dictionary)
		_ = try JSONEncoder().encode(json)
	}

	func testArrayCodable() throws {
		let jsonString = """
		[1,"false", ["A", 4.3231],"3",true]
		"""
		var data = jsonString.data(using: .utf8) ?? Data()
		let json = try JSONDecoder().decode(JSON.self, from: data)
		XCTAssertEqual(json.array?.first?.int, 1)
		XCTAssertEqual(json[1]?.bool, false)
		XCTAssertEqual(json[1]?.string, "false")
		XCTAssertEqual(json[3]?.int, 3)
		XCTAssertEqual(json[2]?[1]?.double ?? 0, 4.3231, accuracy: 0.0001)
		XCTAssertEqual(json.array?[0].bool, true)
		XCTAssertEqual(json.array?.last?.bool, true)
		let jsonList = try JSONDecoder().decode([JSON].self, from: data)
		XCTAssertEqual(jsonList.first?.int, 1)
		XCTAssertEqual(jsonList.last?.bool, true)
		data = try JSONEncoder().encode(json)
		let list = try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
		XCTAssertEqual(list?[0] as? Int, 1)
		XCTAssertEqual((list?[2] as? [Any])?[1] as? Double, 4.3231)
	}

	func testDictionaryCodable() throws {
		let dictionary: [String: Any] = ["number": 9823.212, "name": "NAME", "list": [1234, 4.21223256], "object": ["sub_number": 877.2323, "sub_name": "sub_name"], "bool": true]
		var data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
		let json = try JSONDecoder().decode(JSON.self, from: data)
		XCTAssertNotNil(json.object)
		XCTAssertEqual(json["number"]?.double, 9823.212)
		XCTAssertEqual(json["object"]?["sub_number"]?.double, 877.2323)
		XCTAssertEqual(json["bool"]?.bool, true)
		let jsonDict = try JSONDecoder().decode([String: JSON].self, from: data)
		XCTAssertEqual(jsonDict["number"]?.int, 9823)
		XCTAssertEqual(jsonDict["object"]?["sub_name"], "sub_name")
		data = try JSONEncoder().encode(json)
		var encoderDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
		XCTAssertEqual(encoderDict?["list"] as? [Double], [1234, 4.21223256])
		XCTAssertEqual(encoderDict?["bool"] as? Bool, true)
		data = try JSONEncoder().encode(jsonDict)
		encoderDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
		XCTAssertEqual(encoderDict?["name"] as? String, dictionary["name"] as? String)
		XCTAssertEqual((encoderDict?["object"] as? [String: Any])?["sub_number"] as? Double, 877.2323)
	}

	func testCodableModel() throws {
		let dictionary: [String: Any] = [
			"number": 9823.212,
			"name": "NAME",
			"list": [1234, 4.21223256],
			"object": ["sub_number": 877.2323, "sub_name": "sub_name"],
			"bool": true,
		]
		let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
		let model = try JSONDecoder().decode(CodableModel.self, from: data)
		XCTAssertEqual(model.subName, "sub_name")
	}
}

private struct CodableModel: Codable {
	let name: String
	let number: Double
	let bool: Bool
	let list: [Double]
	private let object: JSON
	var subName: String? {
		object.sub_name?.string
	}
}
