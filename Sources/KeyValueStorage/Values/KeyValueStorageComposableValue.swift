protocol KeyValueStorageComposableValue: Sendable {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue { get }
}

// MARK: - Conformance

extension String: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        .string(self)
    }
}

extension Array: KeyValueStorageComposableValue, KeyValueStorageValue where Element: KeyValueStorageComposableValue {
    var keyValueStoragePrimitiveValue: KeyValueStoragePrimitiveValue {
        let elements = map(\.keyValueStoragePrimitiveValue)
        return .array(elements)
    }

    static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> [Element]? {
        backend.array(for: key)
    }

    func store(for key: String, from backend: some KeyValueStorageBackend) {
        let elements = map(\.keyValueStoragePrimitiveValue)
        backend.setArray(elements, for: key)
    }
}
