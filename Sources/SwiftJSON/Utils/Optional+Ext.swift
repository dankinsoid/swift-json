import Foundation

public extension Optional {

	subscript(or defaultValue: Wrapped) -> Wrapped {
		get {
			self ?? defaultValue
		}
		set {
			self = newValue
		}
	}
}
