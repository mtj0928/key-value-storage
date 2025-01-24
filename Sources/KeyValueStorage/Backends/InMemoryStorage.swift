import Foundation
import os

public final class InMemoryStorage: NSObject, KeyValueStorageBackend {
    private let lockedValues = OSAllocatedUnfairLock<[String: KeyValueStoragePrimitiveValue]>(initialState: [:])
    public var values: [String: KeyValueStoragePrimitiveValue] {
        get { lockedValues.withLock { $0 } }
        set { lockedValues.withLock { $0 = newValue } }
    }

    // MARK: - Write

    public func setBool(_ value: Bool, for key: String) {
        set(value: .bool(value), key: key)
    }
    
    public func setInt(_ value: Int, for key: String) {
        set(value: .int(value), key: key)
    }
    
    public func setFloat(_ value: Float, for key: String) {
        set(value: .float(value), key: key)
    }
    
    public func setDouble(_ value: Double, for key: String) {
        set(value: .double(value), key: key)
    }
    
    public func setString(_ value: String, for key: String) {
        set(value: .string(value), key: key)
    }
    
    public func setURL(_ value: URL, for key: String) {
        set(value: .url(value), key: key)
    }
    
    public func setData(_ value: Data, for key: String) {
        set(value: .data(value), key: key)
    }
    
    public func setArray(_ array: [KeyValueStoragePrimitiveValue], for key: String) {
        set(value: .array(array), key: key)
    }

    public func setDictionary(_ dictionary: [String : KeyValueStoragePrimitiveValue], for key: String) {
        set(value: .dictionary(dictionary), key: key)
    }

    private func set(value: KeyValueStoragePrimitiveValue, key: String) {
        let key = internalKey(key)
        willChangeValue(forKey: key)
        lockedValues.withLock { values in
            values[key] = value
        }
        didChangeValue(forKey: key)
    }

    // MARK: - Read

    public func bool(for key: String) -> Bool {
        read(for: key, default: false)
    }
    
    public func int(for key: String) -> Int {
        read(for: key, default: 0)
    }
    
    public func float(for key: String) -> Float {
        read(for: key, default: 0)
    }
    
    public func double(for key: String) -> Double {
        read(for: key, default: 0)
    }
    
    public func string(for key: String) -> String? {
        read(for: key, default: nil)
    }
    
    public func url(for key: String) -> URL? {
        read(for: key, default: nil)
    }
    
    public func data(for key: String) -> Data? {
        read(for: key, default: nil)
    }
    
    public func array<Element: Sendable>(for key: String) -> [Element]? where Element : KeyValueStorageComposableValue {
        read(for: key, default: nil)
    }

    public func dictionary<Value>(for key: String) -> [String : Value]? where Value : KeyValueStorageComposableValue {
        read(for: key, default: nil)
    }

    private func read<T: Sendable>(for key: String, default defaultValue: T) -> T {
        let key = internalKey(key)
        return lockedValues.withLock { values in
            (values[key]?.anyValue as? T) ?? defaultValue
        }
    }

    public func has(_ key: String) -> Bool {
        let key = internalKey(key)
        return lockedValues.withLock { values in
            values.keys.contains(key)
        }
    }

    public func reset() {
        lockedValues.withLock { values in
            values.removeAll()
        }
    }

    public func observe(_ key: String, changes: @escaping @Sendable () -> Void) -> KeyValueObserveCancellable {
        let key = internalKey(key)
        let observer = KeyValueObserver(onChange: changes)
        addObserver(observer, forKeyPath: key, options: [], context: nil)
        return KeyValueObserveCancellable { [weak self] in
            self?.removeObserver(observer, forKeyPath: key)
        }
    }

    private func internalKey(_ string: String) -> String {
        string.replacingOccurrences(of: ".", with: "_")
    }
}
