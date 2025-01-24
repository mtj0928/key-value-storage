import Foundation

public protocol KeyValueStorageComposableValue: Sendable {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue { get }
}

// MARK: - Conformance

extension Bool: KeyValueStorageComposableValue {
    public var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .bool(self)
    }
}

extension Int: KeyValueStorageComposableValue {
    public var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .int(self)
    }
}

extension Float: KeyValueStorageComposableValue {
    public var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .float(self)
    }
}

extension Double: KeyValueStorageComposableValue {
    public var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .double(self)
    }
}

extension String: KeyValueStorageComposableValue {
    public var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .string(self)
    }
}

extension URL: KeyValueStorageComposableValue {
    public var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .url(self)
    }
}

extension Data: KeyValueStorageComposableValue {
    public var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .data(self)
    }
}

extension Array: KeyValueStorageComposableValue, KeyValueStorageValue where Element: KeyValueStorageComposableValue {
    public var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        let elements = map(\.keyValueStoragePrimitiveValue)
        return .array(elements)
    }

    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        let elements = map(\.keyValueStoragePrimitiveValue)
        backend.setArray(elements, for: key)
    }

    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> [Element]? {
        backend.array(for: key)
    }
}

extension Dictionary: KeyValueStorageComposableValue,
                      KeyValueStorageValue
where Key == String, Value: KeyValueStorageComposableValue {
    public var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        let dictionary = mapValues { $0.keyValueStoragePrimitiveValue }
        return .dictionary(dictionary)
    }

    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        let dictionary = mapValues { $0.keyValueStoragePrimitiveValue }
        backend.setDictionary(dictionary, for: key)
    }

    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Dictionary<Key, Value>? {
        backend.dictionary(for: key)
    }
}
