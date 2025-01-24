import Foundation

public protocol KeyValueStorageValue: Sendable {
    func store(for key: String, from backend: some KeyValueStorageBackend)
    static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Self?
}

// MARK: - Conformance

extension Bool: KeyValueStorageValue {
    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        backend.setBool(self, for: key)
    }
    
    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Bool? {
        backend.has(key) ? backend.bool(for: key) : nil
    }
}

extension Int: KeyValueStorageValue {
    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        backend.setInt(self, for: key)
    }

    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Int? {
        backend.has(key) ? backend.int(for: key) : nil
    }
}

extension Float: KeyValueStorageValue {
    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        backend.setFloat(self, for: key)
    }
    
    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Float? {
        backend.has(key) ? backend.float(for: key) : nil
    }
}

extension Double: KeyValueStorageValue {
    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        backend.setDouble(self, for: key)
    }
    
    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Double? {
        backend.has(key) ? backend.double(for: key) : nil
    }
}

extension String: KeyValueStorageValue {
    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        backend.setString(self, for: key)
    }

    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> String? {
        backend.has(key) ? backend.string(for: key) : nil
    }
}

extension URL: KeyValueStorageValue {
    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        backend.setURL(self, for: key)
    }
    
    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> URL? {
        backend.has(key) ? backend.url(for: key) : nil
    }
}

extension Data: KeyValueStorageValue {
    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        backend.setData(self, for: key)
    }

    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Data? {
        backend.has(key) ? backend.data(for: key) : nil
    }
}

extension Optional: KeyValueStorageValue where Wrapped: KeyValueStorageValue{
    public func store(for key: String, from backend: some KeyValueStorageBackend) {
        self?.store(for: key, from: backend)
    }
    
    public static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Optional<Wrapped>? {
        Wrapped.fetch(for: key, from: backend)
    }
}
