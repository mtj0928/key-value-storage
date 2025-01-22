import Foundation

extension UserDefaults: @retroactive @unchecked Sendable {}

extension UserDefaults: KeyValueStorageBackend {
    func setBool(_ value: Bool, for key: String) {
        set(value, forKey: key)
    }

    func setInt(_ value: Int, for key: String) {
        set(value, forKey: key)
    }

    func setFloat(_ value: Float, for key: String) {
        set(value, forKey: key)
    }

    func setDouble(_ value: Double, for key: String) {
        set(value, forKey: key)
    }

    func setString(_ value: String, for key: String) {
        set(value, forKey: key)
    }
    
    func setURL(_ value: URL, for key: String) {
        set(value, forKey: key)
    }
    
    func setData(_ value: Data, for key: String) {
        set(value, forKey: key)
    }
    
    func setArray(_ array: [KeyValueStoragePrimitiveValue], for key: String) {
        set(array.map(\.anyValue), forKey: key)
    }
    
    func setDictionary(_ dictionary: [String : KeyValueStoragePrimitiveValue], for key: String) {
        set(dictionary.mapValues(\.anyValue), forKey: key)
    }

    func bool(for key: String) -> Bool {
        bool(forKey: key)
    }

    func int(for key: String) -> Int {
        integer(forKey: key)
    }

    func float(for key: String) -> Float {
        float(forKey: key)
    }

    func double(for key: String) -> Double {
        double(forKey: key)
    }

    func string(for key: String) -> String? {
        string(forKey: key)
    }

    func url(for key: String) -> URL? {
        url(forKey: key)
    }

    func data(for key: String) -> Data? {
        data(forKey: key)
    }

    func array<Element>(for key: String) -> [Element]? where Element : KeyValueStorageComposableValue {
        array(forKey: key) as? [Element]
    }
    
    func dictionary<Value>(for key: String) -> [String: Value]? where Value: KeyValueStorageComposableValue {
        dictionary(forKey: key) as? [String: Value]
    }
    
    func has(_ key: String) -> Bool {
        object(forKey: key) != nil
    }

    func reset() {
        let dictionary = dictionaryRepresentation()
        dictionary.keys.forEach { key in
            removeObject(forKey: key)
        }
    }
}
