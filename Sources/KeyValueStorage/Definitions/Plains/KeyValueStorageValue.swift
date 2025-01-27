import Foundation

public protocol KeyValueStorageValue: Sendable {
    var isNil: Bool { get }
    func storedValue() -> (any Sendable)
    static func keyValueStorageValue(from value: (any Sendable)) -> Self?
}

extension KeyValueStorageValue {
    public var isNil: Bool { false }
}

fileprivate protocol PrimitiveStorageValue: Sendable, KeyValueStorageValue {}

extension PrimitiveStorageValue {
    public func storedValue() -> (any Sendable) {
        self
    }

    public static func keyValueStorageValue(from value: (any Sendable)) -> Self? {
        value as? Self
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

extension Array: KeyValueStorageValue where Element: KeyValueStorageValue {
    public func storedValue() -> (any Sendable) {
        map { $0.storedValue() }
    }

    public static func keyValueStorageValue(from value: (any Sendable)) -> [Element]? {
        guard let array = value as? [(any Sendable)] else { return nil }
        return array.compactMap { Element.keyValueStorageValue(from: $0) }
    }
}

extension Dictionary: KeyValueStorageValue where Key == String, Value: KeyValueStorageValue {
    public func storedValue() -> (any Sendable) {
        mapValues { $0.storedValue() }
    }

    public static func keyValueStorageValue(from value: (any Sendable)) -> Dictionary<String, Value>? {
        guard let dictionary = value as? [String: (any Sendable)] else { return nil }
        return dictionary.compactMapValues { Value.keyValueStorageValue(from: $0) }
    }
}

extension Optional: KeyValueStorageValue where Wrapped: KeyValueStorageValue {
    public var isNil: Bool {
        switch self {
        case .none: return true
        case .some(let wrapped): return wrapped.isNil
        }
    }

    public func storedValue() -> (any Sendable) {
        guard let wrapped = self else { return self }
        return wrapped.storedValue()
    }

    public static func keyValueStorageValue(from value: (any Sendable)) ->  Optional<Wrapped>? {
        Wrapped.keyValueStorageValue(from: value)
    }
}

extension KeyValueStorageValue where Self: RawRepresentable, RawValue: KeyValueStorageValue {
    public func storedValue() -> (any Sendable) {
        rawValue.storedValue()
    }

    public static func keyValueStorageValue(from value: (any Sendable)) -> Self? {
        guard let rawValue = RawValue.keyValueStorageValue(from: value) else { return nil }
        return Self(rawValue: rawValue)
    }
}
