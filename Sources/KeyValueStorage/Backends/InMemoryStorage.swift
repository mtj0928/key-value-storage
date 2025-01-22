import Foundation
import os

final class InMemoryStorage: KeyValueStorageBackend {
    private let lockedValues = OSAllocatedUnfairLock<[String: KeyValueStoragePrimitiveValue]>(initialState: [:])
    public var values: [String: KeyValueStoragePrimitiveValue] {
        get { lockedValues.withLock { $0 } }
        set { lockedValues.withLock { $0 = newValue } }
    }

    // MARK: - Write

    func setBool(_ value: Bool, for key: String) {
        set(value: .bool(value), key: key)
    }
    
    func setInt(_ value: Int, for key: String) {
        set(value: .int(value), key: key)
    }
    
    func setFloat(_ value: Float, for key: String) {
        set(value: .float(value), key: key)
    }
    
    func setDouble(_ value: Double, for key: String) {
        set(value: .double(value), key: key)
    }
    
    func setString(_ value: String, for key: String) {
        set(value: .string(value), key: key)
    }
    
    func setURL(_ value: URL, for key: String) {
        set(value: .url(value), key: key)
    }
    
    func setData(_ value: Data, for key: String) {
        set(value: .data(value), key: key)
    }
    
    func setArray(_ array: [KeyValueStoragePrimitiveValue], for key: String) {
        set(value: .array(array), key: key)
    }

    func setDictionary(_ dictionary: [String : KeyValueStoragePrimitiveValue], for key: String) {
        set(value: .dictionary(dictionary), key: key)
    }

    private func set(value: KeyValueStoragePrimitiveValue, key: String) {
        lockedValues.withLock { values in
            values[key] = value
        }
    }

    // MARK: - Read

    func bool(for key: String) -> Bool {
        read(for: key, default: false)
    }
    
    func int(for key: String) -> Int {
        read(for: key, default: 0)
    }
    
    func float(for key: String) -> Float {
        read(for: key, default: 0)
    }
    
    func double(for key: String) -> Double {
        read(for: key, default: 0)
    }
    
    func string(for key: String) -> String? {
        read(for: key, default: nil)
    }
    
    func url(for key: String) -> URL? {
        read(for: key, default: nil)
    }
    
    func data(for key: String) -> Data? {
        read(for: key, default: nil)
    }
    
    func array<Element: Sendable>(for key: String) -> [Element]? where Element : KeyValueStorageComposableValue {
        read(for: key, default: nil)
    }

    func dictionary<Value>(for key: String) -> [String : Value]? where Value : KeyValueStorageComposableValue {
        read(for: key, default: nil)
    }

    private func read<T: Sendable>(for key: String, default defaultValue: T) -> T {
        lockedValues.withLock { values in
            (values[key]?.anyValue as? T) ?? defaultValue
        }
    }

    func has(_ key: String) -> Bool {
        lockedValues.withLock { values in
            values.keys.contains(key)
        }
    }

    func reset() {
        lockedValues.withLock { values in
            values.removeAll()
        }
    }
}
