extension KeyValueStorage {
    subscript<Value: KeyValueStorageValue>(
        dynamicMember keyPath: KeyPath<Keys, KeyDefinition<Value>>
    ) -> Value {
        get {
            let definition = keys[keyPath: keyPath]
            return Value.fetch(for: definition.key, from: backend) ?? definition.defaultValue
        }
        nonmutating set {
            let definition = keys[keyPath: keyPath]
            return newValue.store(for: definition.key, from: backend)
        }
    }
}

struct KeyDefinition<Value: KeyValueStorageValue> {
    let key: String
    let defaultValue: Value

    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    init<Wrapped: KeyValueStorageValue>(key: String) where Value == Optional<Wrapped> {
        self.key = key
        self.defaultValue = nil
    }
}
