import Foundation

/// A representation of JSON data supporting various types including boolean, number, string, array, object, and null.
/// This enum provides a dynamic member lookup for JSON objects, Codable conformance for encoding/decoding,
/// and convenience initializers and accessors for different JSON types.
@dynamicMemberLookup
public enum JSON: Codable {

	/// Represents a boolean value in JSON.
	case bool(Bool)
	/// Represents a numeric value. Uses `Decimal` for precision.
	case number(Decimal)
	/// Represents a string value.
	case string(String)
	/// Represents an array of JSON values.
	case array([JSON])
	/// Represents a JSON object, a dictionary with string keys and JSON values.
	case object([String: JSON])
	/// Represents a null value in JSON.
	case null

	/// Allows accessing JSON object properties using subscript syntax with dynamic member lookup.
	public subscript(dynamicMember member: String) -> JSON? {
		get { self[member] }
		set { self[member] = newValue }
	}

	/// Encodes the JSON value into `Data` using a `ProtobufJSONEncoder`.
	public var data: Data {
		var encoder = ProtobufJSONEncoder()
		putSelf(to: &encoder)
		return encoder.dataResult
	}

	/// Returns a UTF-8 string representation of the JSON value.
	public var utf8String: String {
		String(data: data, encoding: .utf8) ?? ""
	}

	/// Initializer that attempts to create a JSON value from various Swift types.
	@available(*, deprecated, message: "Use init?(_ value: Any) instead")
	public init?(with value: Any) {
		self.init(value)
	}

	/// Initializer that attempts to create a JSON value from various Swift types.
	public init?(_ value: Any?) {
		guard let value else {
			self = .null
			return
		}
		if let json = value as? JSON {
			self = json
			return
		}
		if let int = value as? Int { self = .number(Decimal(int)); return }
		if let db = value as? Double { self = .number(Decimal(db)); return }
		if let db = value as? Decimal { self = .number(db); return }
		if let str = value as? String { self = .string(str); return }
		if let bl = value as? Bool { self = .bool(bl); return }
		if let arr = value as? [Any?] {
			var arrV: [JSON] = []
			for a in arr {
				guard let json = JSON(a) else {
					return nil
				}
				arrV.append(json)
			}
			self = .array(arrV)
			return
		}
		if let dict = value as? [String: Any?] {
			var dictV: [String: JSON] = [:]
			for (key, v) in dict {
				guard let json = JSON(v) else { return nil }
				dictV[key] = json
			}
			self = .object(dictV)
			return
		}
		if value as Any? == nil || value is Void || value is NSNull {
			self = .null
			return
		}
		return nil
	}

	/// Initializer to create JSON value from a UTF-8 encoded data.
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
			let dbl = try scanner.nextNumber()
			self = .number(dbl)
		}
	}

	/// Initializer used by `Decodable` to decode JSON values.
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

	/// Encodes this JSON value into the given encoder.
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
}

public extension JSON {

	/// Enum to categorize JSON types.
	enum Kind: String, CaseIterable {

		case object, array, number, string, boolean, null
	}

	/// Returns the kind of the JSON value (object, array, number, string, boolean, or null).
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

	/// Provides a string representation if the JSON value is a string, or nil otherwise.
	var string: String? {
		get {
			switch self {
			case let .string(str): return str
			default: return nil
			}
		}
		set {
			self = newValue.map { .string($0) } ?? .null
		}
	}

	/// Provides an integer representation if the JSON value is a number that can be represented as an Int, or nil otherwise.
	var int: Int? {
		get {
			switch self {
			case let .string(str): return Int(str)
			case let .number(d): return Int(Double(d))
			default: return nil
			}
		}
		set {
			self = newValue.map { .number(Decimal($0)) } ?? .null
		}
	}

	/// Provides a Decimal representation if the JSON value is a number, or nil otherwise.
	var number: Decimal? {
		get {
			switch self {
			case let .number(d): return d
			case let .string(str): return Decimal(string: str)
			default: return nil
			}
		}
		set {
			self = newValue.map { .number($0) } ?? .null
		}
	}

	/// Provides a double representation if the JSON value is a number that can be represented as a Double, or nil otherwise.
	var double: Double? {
		get {
			switch self {
			case let .number(d): return Double(d)
			case let .string(str): return Double(str)
			default: return nil
			}
		}
		set {
			self = newValue.map { .number(Decimal($0)) } ?? .null
		}
	}

	/// Provides a boolean representation if the JSON value is a boolean, or nil otherwise.
	var bool: Bool? {
		get {
			switch self {
			case let .bool(d): return d
			case let .string(str):
				switch str.lowercased() {
				case "true", "yes", "1", "y", "t": return true
				case "false", "no", "0", "f", "n": return false
				default: return nil
				}
			case let .number(i): if i == 1 || i == 0 { return i == 1 }
			default: return nil
			}
			return nil
		}
		set {
			self = newValue.map { .bool($0) } ?? .null
		}
	}

	/// Provides an array of JSON values if the JSON value is an array, or nil otherwise.
	var array: [JSON]? {
		get {
			if case let .array(d) = self { return d }
			return nil
		}
		set {
			self = newValue.map { .array($0) } ?? .null
		}
	}

	/// Provides a dictionary of String to JSON values if the JSON value is an object, or nil otherwise.
	var object: [String: JSON]? {
		get {
			if case let .object(d) = self { return d }
			return nil
		}
		set {
			self = newValue.map { .object($0) } ?? .null
		}
	}

	/// Checks if the JSON value is of the specified kind.
	func `is`(_ kind: Kind) -> Bool {
		self.kind == kind
	}

	/// Subscript to access or modify elements by path in a JSON object.
	subscript<S: Collection>(path: S, or defaultValue: JSON) -> JSON where S.Element == JSONKeyType {
		get {
			self[path] ?? defaultValue
		}
		set {}
	}

	/// Subscript to access or modify elements by path in a JSON object.
	subscript<S: Collection>(path: S) -> JSON? where S.Element == JSONKeyType {
		get {
			guard !path.isEmpty else { return self }
			switch (self, path[path.startIndex]._jsonKey) {
			case let (.object(dict), .string(string)):
				if let value = dict[string] {
					return value[path.dropFirst()]
				} else {
					return nil
				}
			case let (.array(array), .int(int)):
				if int < array.count, int >= 0 {
					return array[int][path.dropFirst()]
				} else {
					return nil
				}
			default:
				return nil
			}
		}
		set {
			guard !path.isEmpty else {
				if let newValue {
					self = newValue
				}
				return
			}
			switch path[path.startIndex]._jsonKey {
			case let .string(string):
				guard var object else { return }
				if let newValue {
					var value = object[string]
					value[or: [:]][path.dropFirst()] = newValue
					object[string] = value
				} else {
					object[string] = nil
				}
				self = .object(object)
			case let .int(int):
				guard var array, int < array.count, int >= 0 else { return }
				if let newValue {
					array[int][path.dropFirst()] = newValue
				} else {
					array.remove(at: int)
				}
				self = .array(array)
			}
		}
	}

	/// Subscript to access or modify elements by path in a JSON object.
	subscript(path: JSONKeyType...) -> JSON? {
		get { self[path] }
		set { self[path] = newValue }
	}

	/// Subscript to access or modify elements by path in a JSON object.
	subscript(path: JSONKeyType..., or defaultValue: JSON) -> JSON {
		get { self[path, or: defaultValue] }
		set { self[path, or: defaultValue] = newValue }
	}

	/// Subscript to access or modify elements by a CodingKey in a JSON object or array.
	subscript(codingKey: CodingKey) -> JSON? {
		get { self[codingKey._jsonKey.value] }
		set { self[codingKey._jsonKey.value] = newValue }
	}

	/// Subscript to access or modify elements by a CodingKey in a JSON object or array.
	subscript(codingPath: [CodingKey]) -> JSON? {
		get {
			self[codingPath.map { $0._jsonKey.value }]
		}
		set {
			self[codingPath.map { $0._jsonKey.value }] = newValue
		}
	}

	/// Subscript to access or modify elements by a raw representable key in a JSON object.
	subscript<T: RawRepresentable>(key: T) -> JSON? where T.RawValue == String {
		if case let .object(dict) = self { return dict[key.rawValue] }
		return nil
	}

	/// Extracts the raw value from the JSON value. Useful for obtaining native Swift types from JSON.
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
}

public extension JSON? {

	/// Returns the JSON value if it is not nil, or .null otherwise.
	var orNull: JSON {
		get { self[or: .null] }
		set { self = newValue.is(.null) ? .none : .null }
	}

	@available(*, deprecated)
	subscript(index: Int) -> JSON? {
		self?[index]
	}

	@available(*, deprecated)
	subscript(key: String) -> JSON? {
		self?[key]
	}

	@available(*, deprecated)
	subscript<T: RawRepresentable>(key: T) -> JSON? where T.RawValue == String {
		self?[key]
	}
}

public extension JSON {

	var nilIfNull: JSON? {
		self == .null ? nil : self
	}
}

extension JSON: CustomStringConvertible {

	public var description: String {
		stringSlice()
	}

	private func stringSlice(_ intentSize: Int = 0) -> String {
		let indent = [String](repeating: Self.singleIndent, count: intentSize).joined()
		let nextIndent = indent + Self.singleIndent
		switch self {
		case .number, .string, .bool: return utf8String
		case let .array(a): return "[\n\(a.map { nextIndent + $0.stringSlice(intentSize + 1) }.joined(separator: ",\n"))\n\(indent)]"
		case let .object(d): return "{\n\(d.map { "\(nextIndent)\"\($0.key)\": \($0.value.stringSlice(intentSize + 1))" }.sorted().joined(separator: ",\n"))\n\(indent)}"
		case .null: return "null"
		}
	}

	private static let singleIndent = "   "
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

	public typealias FloatLiteralType = Decimal.FloatLiteralType
	public init(floatLiteral value: FloatLiteralType) { self = .number(Decimal(floatLiteral: value)) }
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
		case let (.object(dictionary), .key(i)): return [dictionary[i].key: dictionary[i].value]
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

extension JSON: Comparable {

	public static func > (lhs: JSON, rhs: JSON) -> Bool {
		switch (lhs, rhs) {
		case let (.number(l), .number(r)): return l > r
		case let (.string(l), .string(r)): return l > r
		case let (.array(l), .array(r)): return l.count > r.count
		case let (.object(l), .array(r)): return l.count > r.count
		case let (.object(l), .object(r)): return l.count > r.count
		case let (.array(l), .object(r)): return l.count > r.count
		default: return false
		}
	}

	public static func < (lhs: JSON, rhs: JSON) -> Bool {
		rhs > lhs
	}

	public static func <= (lhs: JSON, rhs: JSON) -> Bool {
		lhs < rhs || lhs == rhs
	}

	public static func >= (lhs: JSON, rhs: JSON) -> Bool {
		lhs > rhs || lhs == rhs
	}
}

public extension JSON {

	/// Merges another JSON into this JSON, whereas primitive values which are not present in this JSON are getting added,
	/// present values getting overwritten, array values getting appended and nested JSONs getting merged the same way.
	///
	/// - parameter other: The JSON which gets merged into this JSON
	///
	/// - throws `ErrorWrongType` if the other JSONs differs in type on the top level.
	mutating func merge(with other: JSON) throws {
		try self.merge(with: other, typecheck: true)
	}

	/// Merges another JSON into this JSON and returns a new JSON, whereas primitive values which are not present in this JSON are getting added,
	/// present values getting overwritten, array values getting appended and nested JSONS getting merged the same way.
	///
	/// - parameter other: The JSON which gets merged into this JSON
	///
	/// - throws `ErrorWrongType` if the other JSONs differs in type on the top level.
	///
	/// - returns: New merged JSON
	func merged(with other: JSON) throws -> JSON {
		var merged = self
		try merged.merge(with: other, typecheck: true)
		return merged
	}

	/// Private woker function which does the actual merging
	/// Typecheck is set to true for the first recursion level to prevent total override of the source JSON
	private mutating func merge(with other: JSON, typecheck: Bool) throws {
		if kind == other.kind {
			switch (self, other) {
			case (var .object(object), let .object(other)):
				for (key, value) in other {
					if object[key] == nil {
						object[key] = value
					} else {
						try object[key]?.merge(with: value, typecheck: false)
					}
				}
				self = .object(object)
			case let (.array(array), .array(other)):
				self = .array(array + other)
			default:
				self = other
			}
		} else {
			if typecheck {
				throw WrongType()
			} else {
				self = other
			}
		}
	}

	static func + (lhs: JSON, rhs: JSON) -> JSON {
		switch (lhs, rhs) {
		case let (.array(l), .array(r)): return .array(l + r)
		case let (.object(l), .object(r)): return .object(l.merging(r) { _, r in r })
		case let (.number(l), .number(r)): return .number(l + r)
		case let (.string(l), .string(r)): return .string(l + r)
		case let (.bool(l), .bool(r)): return .bool(l || r)
		case let (.array(l), r): return .array(l + [r])
		case let (l, .array(r)): return .array([l] + r)
		case (.object, _), (_, .object): return [lhs, rhs]
		case let (.string(l), r): return .string(l + r.stringSlice())
		case let (l, .string(r)): return .string(l.stringSlice() + r)
		default: return [lhs, rhs]
		}
	}
}

private extension JSON {

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

	struct CodingKeys: CodingKey {

		var stringValue: String
		var intValue: Int?

		init?(stringValue: String) { self.stringValue = stringValue }
		init?(intValue: Int) { nil }
		init(_ key: String) { stringValue = key }
	}
}
