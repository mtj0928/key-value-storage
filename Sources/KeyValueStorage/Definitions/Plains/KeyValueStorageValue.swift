import Foundation

public protocol KeyValueStorageValue: Sendable {
    associatedtype StoredValue: Sendable

    var isNil: Bool { get }
    func storedValue() -> StoredValue
    static func keyValueStorageValue(from value: StoredValue) -> Self?
}

extension KeyValueStorageValue {
    public var isNil: Bool { false }
}

fileprivate protocol PrimitiveStorageValue: Sendable, KeyValueStorageValue {}

extension PrimitiveStorageValue {
    public func storedValue() -> Self {
        self
    }

    public static func keyValueStorageValue(from value: Self) -> Self? {
        value
    }
}

// MARK: - Conformance

extension Bool: PrimitiveStorageValue {}
extension Int: PrimitiveStorageValue {}
extension Float: PrimitiveStorageValue {}
extension Double: PrimitiveStorageValue {}
extension String: PrimitiveStorageValue {}
extension URL: PrimitiveStorageValue {}
extension Data: PrimitiveStorageValue {}
extension Date: PrimitiveStorageValue {}

extension Array: KeyValueStorageValue where Element: KeyValueStorageValue {
    public func storedValue() -> [Element.StoredValue] {
        map { $0.storedValue() }
    }

    public static func keyValueStorageValue(from value: [Element.StoredValue]) -> [Element]? {
        value.compactMap { Element.keyValueStorageValue(from: $0) }
    }
}

extension Dictionary: KeyValueStorageValue where Key == String, Value: KeyValueStorageValue {
    public func storedValue() -> [String: Value.StoredValue] {
        mapValues { $0.storedValue() }
    }

    public static func keyValueStorageValue(from value: [String: Value.StoredValue]) -> Dictionary<String, Value>? {
        value.compactMapValues { Value.keyValueStorageValue(from: $0) }
    }
}

extension Optional: KeyValueStorageValue where Wrapped: KeyValueStorageValue {
    public var isNil: Bool {
        switch self {
        case .none: return true
        case .some(let wrapped): return wrapped.isNil
        }
    }

    public func storedValue() -> Wrapped.StoredValue? {
        guard let wrapped = self else { return nil }
        return wrapped.storedValue()
    }

    public static func keyValueStorageValue(from value: Wrapped.StoredValue?) ->  Optional<Wrapped>? {
        value.flatMap { Wrapped.keyValueStorageValue(from: $0) }
    }
}

extension KeyValueStorageValue where Self: RawRepresentable, RawValue: KeyValueStorageValue {
    public func storedValue() -> RawValue.StoredValue {
        rawValue.storedValue()
    }

    public static func keyValueStorageValue(from value: RawValue.StoredValue) -> Self? {
        guard let rawValue = RawValue.keyValueStorageValue(from: value) else { return nil }
        return Self(rawValue: rawValue)
    }
}
