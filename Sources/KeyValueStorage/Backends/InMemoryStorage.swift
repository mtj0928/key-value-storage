import Foundation
import os

public final class InMemoryStorage: NSObject, KeyValueStorageBackend {
    private let lockedValues = OSAllocatedUnfairLock<[String: any Sendable]>(initialState: [:])
    public var values: [String: any Sendable] {
        get { lockedValues.withLock { $0 } }
        set { lockedValues.withLock { $0 = newValue } }
    }

    public func write(_ value: any Sendable, for key: String) {
        let key = internalKey(key)
        willChangeValue(forKey: key)
        lockedValues.withLock { values in
            values[key] = value
        }
        didChangeValue(forKey: key)
    }

    public func read(for key: String) -> (any Sendable)? {
        let key = internalKey(key)
        return lockedValues.withLock { values in
            values[key]
        }
    }

    public func remove(for key: String) {
        let key = internalKey(key)
        return lockedValues.withLock { values in
            values.removeValue(forKey: key)
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
