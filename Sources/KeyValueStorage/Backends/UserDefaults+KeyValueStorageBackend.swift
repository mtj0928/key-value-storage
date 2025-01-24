import Foundation

extension UserDefaults: @retroactive @unchecked Sendable {}

extension UserDefaults: KeyValueStorageBackend {
    public func setBool(_ value: Bool, for key: String) {
        set(value, forKey: key)
    }

    public func setInt(_ value: Int, for key: String) {
        set(value, forKey: key)
    }

    public func setFloat(_ value: Float, for key: String) {
        set(value, forKey: key)
    }

    public func setDouble(_ value: Double, for key: String) {
        set(value, forKey: key)
    }

    public func setString(_ value: String, for key: String) {
        set(value, forKey: key)
    }
    
    public func setURL(_ value: URL, for key: String) {
        set(value, forKey: key)
    }
    
    public func setData(_ value: Data, for key: String) {
        set(value, forKey: key)
    }
    
    public func setArray(_ array: [KeyValueStoragePrimitiveValue], for key: String) {
        set(array.map(\.anyValue), forKey: key)
    }
    
    public func setDictionary(_ dictionary: [String : KeyValueStoragePrimitiveValue], for key: String) {
        set(dictionary.mapValues(\.anyValue), forKey: key)
    }

    public func bool(for key: String) -> Bool {
        bool(forKey: key)
    }

    public func int(for key: String) -> Int {
        integer(forKey: key)
    }

    public func float(for key: String) -> Float {
        float(forKey: key)
    }

    public func double(for key: String) -> Double {
        double(forKey: key)
    }

    public func string(for key: String) -> String? {
        string(forKey: key)
    }

    public func url(for key: String) -> URL? {
        url(forKey: key)
    }

    public func data(for key: String) -> Data? {
        data(forKey: key)
    }

    public func array<Element>(for key: String) -> [Element]? where Element : KeyValueStorageComposableValue {
        array(forKey: key) as? [Element]
    }
    
    public func dictionary<Value>(for key: String) -> [String: Value]? where Value: KeyValueStorageComposableValue {
        dictionary(forKey: key) as? [String: Value]
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
