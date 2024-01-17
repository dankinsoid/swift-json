import Foundation

@dynamicMemberLookup
public enum JSON: Codable {

	case bool(Bool)
	case number(Decimal)
	case string(String)
	case array([JSON])
	case object([String: JSON])
	case null

	public subscript(dynamicMember member: String) -> JSON {
		get { self[member] ?? .null }
		set { self[member] = newValue }
	}

	public var data: Data {
		var encoder = ProtobufJSONEncoder()
		putSelf(to: &encoder)
		return encoder.dataResult
	}

	public var utf8String: String {
		String(data: data, encoding: .utf8) ?? ""
	}

	public init?(with value: Any) {
		if let bl = value as? Bool { self = .bool(bl); return }
		if let int = value as? Int { self = .number(Decimal(int)); return }
		if let db = value as? Decimal { self = .number(db); return }
		if let db = value as? Double { self = .number(Decimal(db)); return }
		if let str = value as? String { self = .string(str); return }
		if let arr = value as? [Any] {
			var arrV: [JSON] = []
			for a in arr {
				guard let json = JSON(with: a) else { return nil }
				arrV.append(json)
			}
			self = .array(arrV)
			return
		}
		if let dict = value as? [String: Any] {
			var dictV: [String: JSON] = [:]
			for (key, v) in dict {
				guard let json = JSON(with: v) else { return nil }
				dictV[key] = json
			}
			self = .object(dictV)
			return
		}
		return nil
	}

	public init(from jsonUTF8Data: Data) throws {
		self = try jsonUTF8Data.withUnsafeBytes { rawPointer -> JSON in
			let source = rawPointer.bindMemory(to: UInt8.self)
			var scanner = JSONScanner(source: source, messageDepthLimit: .max)
			return try JSON(from: &scanner)
		}
	}

	init(from scanner: inout JSONScanner) throws {
		let c = try scanner.peekOneCharacter()
		switch c {
		case "[":
			var array: [JSON] = []
			try scanner.skipRequiredArrayStart()
			if !scanner.skipOptionalArrayEnd() {
				try array.append(JSON(from: &scanner))
				while !scanner.skipOptionalArrayEnd() {
					try scanner.skipRequiredComma()
					try array.append(JSON(from: &scanner))
				}
			}
			self = .array(array)
		case "{":
			var object: [String: JSON] = [:]
			try scanner.skipRequiredObjectStart()
			if !scanner.skipOptionalObjectEnd() {
				let key = try scanner.nextKey()
				try scanner.skipRequiredColon()
				let value = try JSON(from: &scanner)
				object[key] = value
				while !scanner.skipOptionalObjectEnd() {
					try scanner.skipRequiredComma()
					let key = try scanner.nextKey()
					try scanner.skipRequiredColon()
					let value = try JSON(from: &scanner)
					object[key] = value
				}
			}
			self = .object(object)
		case "t", "f":
			self = try .bool(scanner.nextBool())
		case "\"":
			self = try .string(scanner.nextQuotedString())
		case "n":
			if scanner.skipOptionalNull() {
				self = .null
			} else {
				throw JSONDecodingError.failure
			}
		default:
			let dbl = try scanner.nextDecimal()
			self = .number(dbl)
		}
	}

	public init(from decoder: Decoder) throws {
		if var unkeyedContainer = try? decoder.unkeyedContainer() {
			var array: [JSON] = []
			while !unkeyedContainer.isAtEnd {
				let el = try unkeyedContainer.decode(JSON.self)
				array.append(el)
			}
			self = .array(array)
			return
		}
		if let keyedContainer = try? decoder.container(keyedBy: CodingKeys.self) {
			var dict: [String: JSON] = [:]
			try keyedContainer.allKeys.forEach {
				let j = try keyedContainer.decode(JSON.self, forKey: $0)
				dict[$0.stringValue] = j
			}
			self = .object(dict)
			return
		}
		let singleContainer = try decoder.singleValueContainer()
		if let b = try? singleContainer.decode(Bool.self) { self = .bool(b); return }
		if let d = try? singleContainer.decode(Decimal.self) { self = .number(d); return }
		if let s = try? singleContainer.decode(String.self) { self = .string(s); return }
		if singleContainer.decodeNil() { self = .null; return }
		throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON data"))
	}

	public func encode(to encoder: Encoder) throws {
		var singleContainer = encoder.singleValueContainer()
		switch self {
		case let .bool(b): try singleContainer.encode(b)
		case let .number(d): try singleContainer.encode(d)
		case let .string(s): try singleContainer.encode(s)
		case .null: try singleContainer.encodeNil()
		case let .array(a):
			var unkeyedContainer = encoder.unkeyedContainer()
			try unkeyedContainer.encode(contentsOf: a)
		case let .object(d):
			var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
			try d.forEach {
				try keyedContainer.encode($0.value, forKey: CodingKeys($0.key))
			}
		}
	}

	func putSelf(to encoder: inout ProtobufJSONEncoder) {
		switch self {
		case let .object(object):
			let sep = encoder.separator
			encoder.separator = nil
			encoder.openCurlyBracket()
			for (key, value) in object {
				encoder.startField(name: key)
				value.putSelf(to: &encoder)
			}
			encoder.closeCurlyBracket()
			encoder.separator = sep
		case let .array(array):
			let sep = encoder.separator
			encoder.separator = nil
			encoder.openSquareBracket()
			if let value = array.first {
				value.putSelf(to: &encoder)
				var index = 1
				while index < array.count {
					encoder.comma()
					array[index].putSelf(to: &encoder)
					index += 1
				}
			}
			encoder.closeSquareBracket()
			encoder.separator = sep
		case let .bool(bool): encoder.putBoolValue(value: bool)
		case let .number(number): encoder.putDecimalValue(value: number)
		case let .string(string): encoder.putStringValue(value: string)
		case .null: encoder.putNullValue()
		}
	}

	private struct CodingKeys: CodingKey {
		var stringValue: String
		var intValue: Int?

		init?(stringValue: String) { self.stringValue = stringValue }
		init?(intValue: Int) { nil }
		init(_ key: String) { stringValue = key }
	}
}

public extension JSON {

	enum Kind: String, CaseIterable {

		case object, array, number, string, boolean, null
	}

	var kind: Kind {
		switch self {
		case .array: return .array
		case .object: return .object
		case .bool: return .boolean
		case .number: return .number
		case .null: return .null
		case .string: return .string
		}
	}

	var value: Any? {
		switch self {
		case let .array(ar): return ar
		case let .object(d): return d
		case let .bool(b): return b
		case let .number(d): return d
		case let .string(s): return s
		case .null: return nil
		}
	}

	var string: String? { extract() as? String }

	var int: Int? {
		switch self {
		case let .string(str): return Int(str)
		case let .number(d): return Int((d as NSDecimalNumber).intValue)
		default: return nil
		}
	}

	var number: Decimal? {
		switch self {
		case let .number(d): return d
		default: return nil
		}
	}

	var double: Double? {
		switch self {
		case let .number(d): return (d as NSDecimalNumber).doubleValue
		case let .string(str): return Double(str)
		default: return nil
		}
	}

	var bool: Bool? {
		switch self {
		case let .bool(d): return d
		case let .string(str):
			switch str.lowercased() {
			case "true", "yes", "1": return true
			case "false", "no", "0": return false
			default: return nil
			}
		case let .number(i): if i == 1 || i == 0 { return i == 1 }
		default: return nil
		}
		return nil
	}

	var array: [JSON]? {
		if case let .array(d) = self { return d }
		return nil
	}

	var object: [String: JSON]? {
		if case let .object(d) = self { return d }
		return nil
	}

	var isNull: Bool { self == .null }

	subscript(index: Int) -> JSON? {
		get {
			if case let .array(arr) = self {
				return index < arr.count && index >= 0 ? arr[index] : nil
			}
			return nil
		}
		set {
			if case var .array(arr) = self {
				if index < arr.count, index >= 0 {
					if let value = newValue {
						arr[index] = value
					} else {
						arr.remove(at: index)
					}
					self = .array(arr)
				}
			}
		}
	}

	subscript(key: String) -> JSON? {
		get {
			if case let .object(dict) = self { return dict[key] }
			return nil
		} set {
			if case var .object(dict) = self {
				dict[key] = newValue
				self = .object(dict)
			}
		}
	}

	subscript(codingKey: CodingKey) -> JSON? {
		switch self {
		case let .array(array):
			if let i = codingKey.intValue, i >= 0, i < array.count {
				return array[i]
			} else {
				return nil
			}
		case let .object(dictionary):
			return dictionary[codingKey.stringValue]
		default:
			return nil
		}
	}

	subscript<T: RawRepresentable>(key: T) -> JSON? where T.RawValue == String {
		if case let .object(dict) = self { return dict[key.rawValue] }
		return nil
	}

	func extract() -> Any? {
		switch self {
		case let .array(ar): return ar.map { $0.extract() }
		case let .object(d): return d.mapValues { $0.extract() }
		case let .bool(b): return b
		case let .number(d): return d
		case let .string(s): return s
		case .null: return nil
		}
	}

	func toArray() -> [Any]? { extract() as? [Any] }
	func toDictionary() -> [String: Any]? { extract() as? [String: Any] }
}

public extension JSON? {

	subscript(index: Int) -> JSON? {
		self?[index]
	}

	subscript(key: String) -> JSON? {
		self?[key]
	}

	subscript<T: RawRepresentable>(key: T) -> JSON? where T.RawValue == String {
		self?[key]
	}
}

extension JSON: CustomStringConvertible {

	public var description: String {
		var str = self.stringSlice()
		JSON.makeOffsets(&str)
		return str
	}

	private func stringSlice() -> String {
		switch self {
		case let .bool(b): return "\(b)"
		case let .number(d): return d.description
		case let .string(str): return "\"\(str)\""
		case let .array(a): return "[\(a.map { $0.stringSlice() }.joined(separator: ", "))]"
		case let .object(d): return "{\n\(d.map { "\"\($0.key)\": \($0.value.stringSlice())" }.joined(separator: ",\n"))\n}"
		case .null: return "null"
		}
	}

	private static func makeOffsets(_ s: inout String) {
		var lb = 0
		var comp = s.components(separatedBy: "\n")
		for i in 0 ..< comp.count {
			let l = comp[i].components(separatedBy: "{").count - comp[i].components(separatedBy: "}").count
			if l < 0 { lb += l }
			comp[i] = [String](repeating: "   ", count: lb).joined() + comp[i]
			if l > 0 { lb += l }
		}
		s = comp.joined(separator: "\n")
	}
}

extension JSON: ExpressibleByArrayLiteral {

	public typealias ArrayLiteralElement = JSON
	public init(arrayLiteral elements: JSON...) { self = .array(elements) }
}

extension JSON: ExpressibleByDictionaryLiteral {

	public typealias Key = String
	public typealias Value = JSON

	public init(dictionaryLiteral elements: (String, JSON)...) {
		var dict: [String: JSON] = [:]
		elements.forEach { dict[$0.0] = $0.1 }
		self = .object(dict)
	}
}

extension JSON: ExpressibleByFloatLiteral {

	public typealias FloatLiteralType = Double
	public init(floatLiteral value: Double) { self = .number(Decimal(value)) }
}

extension JSON: ExpressibleByIntegerLiteral {

	public typealias IntegerLiteralType = Int
	public init(integerLiteral value: Int) { self = .number(Decimal(value)) }
}

extension JSON: ExpressibleByBooleanLiteral {

	public typealias BooleanLiteralType = Bool
	public init(booleanLiteral value: Bool) { self = .bool(value) }
}

extension JSON: ExpressibleByStringLiteral {

	public typealias StringLiteralType = String
	public init(stringLiteral value: String) { self = .string(value) }
}

extension JSON: Collection {

	public typealias Element = JSON

	public var count: Int {
		switch self {
		case let .array(array): return array.count
		case let .object(dictionary): return dictionary.count
		default: return 1
		}
	}

	public enum Index: Comparable {
  
		case int(Int), key(Dictionary<String, JSON>.Index), single

		public static func < (lhs: JSON.Index, rhs: JSON.Index) -> Bool {
			switch (lhs, rhs) {
			case let (.int(i), .int(j)): return i < j
			case let (.key(i), .key(j)): return i < j
			case (.single, .single): return false
			case let (.single, .int(i)): return i > 0
			case let (.int(i), .single): return i < 0
			default: fatalError("Invalid Index types")
			}
		}

		public static func == (lhs: JSON.Index, rhs: JSON.Index) -> Bool {
			switch (lhs, rhs) {
			case let (.int(i), .int(j)): return i == j
			case let (.key(i), .key(j)): return i == j
			case (.single, .single): return true
			default: return false
			}
		}
	}

	public var startIndex: Index {
		switch self {
		case let .array(array): return .int(array.startIndex)
		case let .object(dictionary): return .key(dictionary.startIndex)
		default: return .single
		}
	}

	public var endIndex: Index {
		switch self {
		case let .array(array): return .int(array.endIndex)
		case let .object(dictionary): return .key(dictionary.endIndex)
		default: return .single
		}
	}

	public func index(after i: Index) -> Index {
		switch (self, i) {
		case let (.array(array), .int(j)): return .int(array.index(after: j))
		case let (.object(dictionary), .key(j)): return .key(dictionary.index(after: j))
		case let (.object(dictionary), .int(j)): return .int(Array(dictionary).index(after: j))
		case (_, .single): return .single
		default: fatalError("Invalid index type")
		}
	}

	public subscript(position: JSON.Index) -> JSON {
		switch (self, position) {
		case let (.array(array), .int(i)): return array[i]
		case let (.object(dictionary), .key(i)): return dictionary[i].value
		case let (.object(dictionary), .int(i)): return Array(dictionary)[i].value
		case (_, .single): return self
		default: fatalError("Invalid index type")
		}
	}
}

extension JSON: Hashable {

	public func hash(into hasher: inout Hasher) {
		switch self {
		case let .bool(b): b.hash(into: &hasher)
		case let .number(d): d.hash(into: &hasher)
		case let .string(s): s.hash(into: &hasher)
		case let .array(a): a.hash(into: &hasher)
		case let .object(d): d.hash(into: &hasher)
		case .null: JSON?.none.hash(into: &hasher)
		}
	}

	public static func == (_ lhs: JSON, _ rhs: JSON) -> Bool {
		switch (lhs, rhs) {
		case let (.bool(l), .bool(r)): return l == r
		case let (.number(l), .number(r)): return l == r
		case let (.string(l), .string(r)): return l == r
		case let (.array(l), .array(r)): return l == r
		case let (.object(l), .object(r)): return l == r
		case (.null, .null): return true
		default: return false
		}
	}
}
