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
