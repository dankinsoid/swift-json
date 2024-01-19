import SwiftJSON
import XCTest

class DictionaryTests: XCTestCase {

	func testGetter() {
		let dictionary = ["number": 9823.212, "name": "NAME", "list": [1234, 4.212], "object": ["sub_number": 877.2323, "sub_name": "sub_name"], "bool": true] as [String: Any]
		let json = JSON(dictionary).orNull
		XCTAssertEqual((json.object!["number"]! as JSON).double!, 9823.212)
		XCTAssertEqual((json.object!["name"]! as JSON).string!, "NAME")
		XCTAssertEqual(((json.object!["list"]! as JSON).array![0] as JSON).int!, 1234)
		XCTAssertEqual(((json.object!["list"]! as JSON).array![1] as JSON).double!, 4.212)
		XCTAssertEqual(((json.object!["object"]?.object)?["sub_number"] as? JSON)?.double, 877.2323)
		XCTAssertTrue(json.object!["null"] == nil)
	}

	func testSetter() {
		var json: JSON = ["test": "case"]
		XCTAssertEqual(json.object!, ["test": "case"])
		json.object = ["name": "NAME"]
		XCTAssertEqual(json.object!, ["name": "NAME"])
	}
}
