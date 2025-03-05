import Foundation

/// A  protocol which can be stored.
public protocol KeyValueStorageValue: Sendable {
    /// A raw value which can be store in the backend.
    associatedtype StoredRawValue: Sendable

    /// A boolean value indicating the value is `nil` or not.
    var isNil: Bool { get }

    /// Serialize the value to the raw value which can be store in the backend.
    func serialize() -> StoredRawValue

    /// Deserialize  the stored raw value to this type.
    /// `nil` is returned if the deserialize is failed.
    static func deserialize(from value: StoredRawValue) -> Self?
}

extension KeyValueStorageValue {
    public var isNil: Bool { false }
}

fileprivate protocol PrimitiveStorageValue: Sendable, KeyValueStorageValue {}

extension PrimitiveStorageValue {
    public func serialize() -> Self {
        self
    }

    public static func deserialize(from value: Self) -> Self? {
        value
    }
}

// MARK: - Conformance

extension Bool: PrimitiveStorageValue {}
extension Int: PrimitiveStorageValue {}
extension Float: PrimitiveStorageValue {}
extension Double: PrimitiveStorageValue {}
extension String: PrimitiveStorageValue {}
extension Data: PrimitiveStorageValue {}
extension Date: PrimitiveStorageValue {}

extension Array: KeyValueStorageValue where Element: KeyValueStorageValue {
    public func serialize() -> [Element.StoredRawValue] {
        map { $0.serialize() }
    }

    public static func deserialize(from value: [Element.StoredRawValue]) -> [Element]? {
        value.compactMap { Element.deserialize(from: $0) }
    }
}

extension Dictionary: KeyValueStorageValue where Key == String, Value: KeyValueStorageValue {
    public func serialize() -> [String: Value.StoredRawValue] {
        mapValues { $0.serialize() }
    }

    public static func deserialize(from value: [String: Value.StoredRawValue]) -> Dictionary<String, Value>? {
        value.compactMapValues { Value.deserialize(from: $0) }
    }
}

extension Optional: KeyValueStorageValue where Wrapped: KeyValueStorageValue {
    public var isNil: Bool {
        switch self {
        case .none: return true
        case .some(let wrapped): return wrapped.isNil
        }
    }

    public func serialize() -> Wrapped.StoredRawValue? {
        guard let wrapped = self else { return nil }
        return wrapped.serialize()
    }

    public static func deserialize(from value: Wrapped.StoredRawValue?) ->  Optional<Wrapped>? {
        value.flatMap { Wrapped.deserialize(from: $0) }
    }
}

extension KeyValueStorageValue where Self: RawRepresentable, RawValue: KeyValueStorageValue {
    public func serialize() -> RawValue.StoredRawValue {
        rawValue.serialize()
    }

    public static func deserialize(from value: RawValue.StoredRawValue) -> Self? {
        guard let rawValue = RawValue.deserialize(from: value) else { return nil }
        return Self(rawValue: rawValue)
    }
}
