@preconcurrency import Combine
import Observation
import os

typealias KeyValueStoragePublisher = AsyncPublisher<AnyPublisher<Void, Never>>

extension KeyValueStorage {
    subscript<Value: KeyValueStorageValue>(
        dynamicMember keyPath: KeyPath<Keys, KeyDefinition<Value>>
    ) -> Value {
        get {
            let definition = keys[keyPath: keyPath]
            definition.record()
            definition.observeIfNeed(backend)
            return Value.fetch(for: definition.key, from: backend) ?? definition.defaultValue
        }
        nonmutating set {
            let definition = keys[keyPath: keyPath]
            return newValue.store(for: definition.key, from: backend)
        }
    }

    func publisher<Value: KeyValueStorageValue>(key: KeyPath<Keys, KeyDefinition<Value>>) -> any Publisher<Void, Never> {
        let definition = keys[keyPath: key]
        definition.observeIfNeed(backend)
        return definition.publisher
    }

    func stream<Value: KeyValueStorageValue>(key: KeyPath<Keys, KeyDefinition<Value>>) -> KeyValueStoragePublisher {
        publisher(key: key).eraseToAnyPublisher().values
    }
}

@Observable
final class KeyDefinition<Value: KeyValueStorageValue>: Sendable {
    let key: String
    let defaultValue: Value
    var publisher: any Publisher<Void, Never> { subject }
    private let subject = PassthroughSubject<Void, Never>()

    private let logger = Logger(subsystem: "KeyValueStorage", category: "KeyDefinition")
    private let observeCancellable = OSAllocatedUnfairLock<KeyValueObserveCancellable?>(uncheckedState: nil)

    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        validate(key: key)
    }

    init<Wrapped: KeyValueStorageValue>(key: String) where Value == Optional<Wrapped> {
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
