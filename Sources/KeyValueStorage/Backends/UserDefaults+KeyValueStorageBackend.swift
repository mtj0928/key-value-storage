import Foundation

extension UserDefaults: @retroactive @unchecked Sendable {}

extension UserDefaults: KeyValueStorageBackend {
    public func read(for key: String) -> (any Sendable)? {
        guard let anyObject = object(forKey: key) else { return nil }
        let anySendable: (any Sendable)? = cast(anyObject)
        return anySendable
    }

    public func write(_ value: any Sendable, for key: String) {
        set(value, forKey: key)
    }

    public func remove(for key: String) {
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

    public func observe(_ key: String, onChange: @escaping @Sendable () -> Void) -> KeyValueObserveCancellable {
        let observer = KeyValueObserver(onChange: onChange)
        addObserver(observer, forKeyPath: key, options: [], context: nil)
        return KeyValueObserveCancellable { [weak self] in
            self?.removeObserver(observer, forKeyPath: key)
        }
    }
}

private func cast<T: Sendable>(_ value: Any) -> T? {
    value as? T
}
