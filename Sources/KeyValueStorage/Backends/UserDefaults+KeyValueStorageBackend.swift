import Foundation

extension UserDefaults: @retroactive @unchecked Sendable {}

extension UserDefaults: KeyValueStorageBackend {
    public func read(for key: String) -> (any Sendable)? {
        guard let anyObject = object(forKey: key) else { return nil }
        let anySendable: (any Sendable)? = cast(anyObject)
        return anySendable
    }

    public func write(_ value: any Sendable, for key: String) {
        validate(value: value)
        set(value, forKey: key)
    }

    public func delete(for key: String) {
        removeObject(forKey: key)
    }

    public func has(_ key: String) -> Bool {
        object(forKey: key) != nil
    }

    public func reset() {
        let dictionary = dictionaryRepresentation()
        dictionary.keys.forEach { key in
            removeObject(forKey: key)
        }
    }

    public func observe(_ key: String, changes: @escaping @Sendable () -> Void) -> KeyValueObserveCancellable {
        let observer = KeyValueObserver(onChange: changes)
        addObserver(observer, forKeyPath: key, options: [], context: nil)
        return KeyValueObserveCancellable { [weak self] in
            self?.removeObserver(observer, forKeyPath: key)
        }
    }
}

extension UserDefaults {
    private func validate(value: any Sendable) {
        if value is Bool ||
            value is Int ||
            value is Double ||
            value is Float ||
            value is String ||
            value is URL ||
            value is Data ||
            value is Date {
            return
        }

        if let value = value as? [String: any Sendable] {
            value.values.forEach(validate(value:))
            return
        }
        
        if let value = value as? [any Sendable] {
            value.forEach(validate(value:))
            return
        }

        assertionFailure("Invalid value type \(Mirror(reflecting: value).subjectType)")
    }
}

private func cast<T: Sendable>(_ value: Any) -> T? {
    value as? T
}
