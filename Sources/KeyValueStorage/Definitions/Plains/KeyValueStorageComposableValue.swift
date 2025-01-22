import Foundation

protocol KeyValueStorageComposableValue: Sendable {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue { get }
}

// MARK: - Conformance

extension Bool: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .bool(self)
    }
}

extension Int: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .int(self)
    }
}

extension Float: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .float(self)
    }
}

extension Double: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .double(self)
    }
}

extension String: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .string(self)
    }
}

extension URL: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .url(self)
    }
}

extension Data: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .data(self)
    }
}

extension Array: KeyValueStorageComposableValue, KeyValueStorageValue where Element: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        let elements = map(\.keyValueStoragePrimitiveValue)
        return .array(elements)
    }

    func store(for key: String, from backend: some KeyValueStorageBackend) {
        let elements = map(\.keyValueStoragePrimitiveValue)
        backend.setArray(elements, for: key)
    }

    static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> [Element]? {
        backend.array(for: key)
    }
}

extension Dictionary: KeyValueStorageComposableValue,
                      KeyValueStorageValue
where Key == String, Value: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        let dictionary = mapValues { $0.keyValueStoragePrimitiveValue }
        return .dictionary(dictionary)
    }

    func store(for key: String, from backend: some KeyValueStorageBackend) {
        let dictionary = mapValues { $0.keyValueStoragePrimitiveValue }
        backend.setDictionary(dictionary, for: key)
    }

    static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Dictionary<Key, Value>? {
        backend.dictionary(for: key)
    }
}
