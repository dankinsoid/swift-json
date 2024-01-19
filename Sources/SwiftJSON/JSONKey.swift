import Foundation

public protocol JSONKeyType {

	var _jsonKey: JSONKey { get }
}

extension Int: JSONKeyType {

	public var _jsonKey: JSONKey { .int(self) }
}

extension String: JSONKeyType {

	public var _jsonKey: JSONKey { .string(self) }
}

public extension CodingKey {

	var _jsonKey: JSONKey {
		if let intValue { return .int(intValue) }
		return .string(stringValue)
	}
}

public enum JSONKey {

	case string(String)
	case int(Int)

	var value: JSONKeyType {
		switch self {
		case let .string(string): return string
		case let .int(int): return int
		}
	}
}
