@preconcurrency import Combine
import Observation
import os

extension KeyValueStorage {
    public subscript<Value: KeyValueStorageValue>(
        dynamicMember keyPath: KeyPath<Keys, KeyDefinition<Value>>
    ) -> Value {
        get {
            let definition = keys[keyPath: keyPath]
            definition.record()
            definition.observeIfNeed(backend)
            let rawValue = backend.read(for: definition.key) as? Value.StoredRawValue
            return rawValue.flatMap { Value.deserialize(from: $0) } ?? definition.defaultValue
        }
        nonmutating set {
            let definition = keys[keyPath: keyPath]
            if newValue.isNil {
                backend.remove(for: definition.key)
            } else {
                let rawValue = newValue.serialize()
                backend.write(rawValue, for: definition.key)
            }
        }
    }

    public func publisher<Value: KeyValueStorageValue>(key: KeyPath<Keys, KeyDefinition<Value>>) -> any Publisher<Void, Never> {
        let definition = keys[keyPath: key]
        definition.observeIfNeed(backend)
        return definition.publisher
    }

    public func stream<Value: KeyValueStorageValue>(key: KeyPath<Keys, KeyDefinition<Value>>) -> KeyValueStoragePublisher {
        publisher(key: key).eraseToAnyPublisher().values
    }

    public func remove<Value: KeyValueStorageValue>(key: KeyPath<Keys, KeyDefinition<Value>>) {
        let definition = keys[keyPath: key]
        backend.remove(for: definition.key)
    }
}

/// A key definition for ``KeyValueStorageValue``
///
/// This is an example of this class.
/// ```swift
/// let counter = KeyDefinition(key: "counter", defaultValue: 0)
/// ```
@Observable
public final class KeyDefinition<Value: KeyValueStorageValue>: Sendable {
    public let key: String
    public let defaultValue: Value

    var publisher: any Publisher<Void, Never> { subject }
    private let subject = PassthroughSubject<Void, Never>()

    private let logger = Logger(subsystem: "KeyValueStorage", category: "KeyDefinition")
    private let observeCancellable = OSAllocatedUnfairLock<KeyValueObserveCancellable?>(uncheckedState: nil)

    public init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        validate(key: key)
    }

    public init<Wrapped: KeyValueStorageValue>(key: String) where Value == Optional<Wrapped> {
        self.key = key
        self.defaultValue = nil
        validate(key: key)
    }

    deinit {
        observeCancellable.withLock { $0?.cancel() }
    }

    private func validate(key: String) {
        if key.contains(".") {
            logger.warning("Observing \"\(key)\" doesn't work because it has \".\".")
        }
    }

    func record() {
        access(keyPath: \.key)
    }

    func observeIfNeed(_ backend: some KeyValueStorageBackend) {
        observeCancellable.withLock { cancellable in
            if cancellable != nil {
                return
            }

            cancellable = backend.observe(key) { [weak self] in
                self?.withMutation(keyPath: \.key) {}
                self?.subject.send()
            }
        }
    }
}
