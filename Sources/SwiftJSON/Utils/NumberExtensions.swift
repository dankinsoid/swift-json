import Foundation

protocol SignedBitPatternInitializable: FixedWidthInteger, SignedInteger
	where Self.Magnitude: UnsignedBitPatternInitializable, Self.Magnitude.Signed == Self
{
	init(bitPattern: Magnitude)
}

protocol UnsignedBitPatternInitializable: FixedWidthInteger, UnsignedInteger where Signed.Magnitude == Self {

	associatedtype Signed: SignedBitPatternInitializable
	init(bitPattern: Signed)
}

extension Int: SignedBitPatternInitializable {}
extension Int8: SignedBitPatternInitializable {}
extension Int16: SignedBitPatternInitializable {}
extension Int32: SignedBitPatternInitializable {}
extension Int64: SignedBitPatternInitializable {}

extension UInt: UnsignedBitPatternInitializable { typealias Signed = Int }
extension UInt8: UnsignedBitPatternInitializable { typealias Signed = Int8 }
extension UInt16: UnsignedBitPatternInitializable { typealias Signed = Int16 }
extension UInt32: UnsignedBitPatternInitializable { typealias Signed = Int32 }
extension UInt64: UnsignedBitPatternInitializable { typealias Signed = Int64 }

public extension Decimal {

	var fractionLength: Int { max(-exponent, 0) }
}

extension Double {

	init(_ value: Decimal) {
		self = (value as NSDecimalNumber).doubleValue
	}
}
