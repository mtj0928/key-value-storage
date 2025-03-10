@preconcurrency import Combine
import Foundation
import Observation
import os

extension KeyValueStorage {
    public subscript<Value: Codable>(
        dynamicMember keyPath: KeyPath<Keys, JSONKeyDefinition<Value>>
    ) -> Value {
        get {
            let definition = keys[keyPath: keyPath]
            definition.record()
            definition.observeIfNeed(backend)
            do {
                guard let data = backend.read(for: definition.key) as? Data else {
                    return definition.defaultValue
                }
                return try definition.decoder.decode(Value.self, from: data)
            } catch {
                assertionFailure("Should not be called: \(error)")
                return definition.defaultValue
            }
        }
        nonmutating set {
            let definition = keys[keyPath: keyPath]
            do {
                let data = try definition.encoder.encode(newValue)
                backend.write(data, for: definition.key)
            } catch {
                assertionFailure("Should not be called: \(error)")
            }
        }
    }

    public func publisher<Value: Codable>(key: KeyPath<Keys, JSONKeyDefinition<Value>>) -> any Publisher<Void, Never> {
        let definition = keys[keyPath: key]
        definition.observeIfNeed(backend)
        return definition.publisher
    }

    public func stream<Value: Codable>(key: KeyPath<Keys, JSONKeyDefinition<Value>>) -> KeyValueStoragePublisher {
        publisher(key: key).eraseToAnyPublisher().values
    }

    public func remove<Value: Codable>(key: KeyPath<Keys, JSONKeyDefinition<Value>>) {
        let definition = keys[keyPath: key]
        backend.remove(for: definition.key)
    }
}

/// A key definition and the value is converted to `Data` in JSON.
///
/// This is an example of the key.
/// ```swift
/// let foo = JSONKeyDefinition<Foo?>(key: "foo")
/// ```
@Observable
public final class JSONKeyDefinition<Value: Codable & Sendable>: Sendable {
    /// A key of the value.
    public let key: String

    /// A default value when a value is not store in the backend.
    public let defaultValue: Value

    /// An encoder converting a value to `Data`.
    public let encoder: JSONEncoder

    /// A decoder converting `Data` to a value.
    public let decoder: JSONDecoder

    var publisher: any Publisher<Void, Never> { subject }
    private let subject = PassthroughSubject<Void, Never>()

    private let logger = Logger(subsystem: "KeyValueStorage", category: "JSONKeyDefinition")
    private let observeCancellable = OSAllocatedUnfairLock<KeyValueObserveCancellable?>(uncheckedState: nil)

    public init(
        key: String,
        defaultValue: Value,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.encoder = encoder
        self.decoder = decoder
        validate(key: key)
    }

    public init<Wrapped: Codable>(
        key: String,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) where Value == Optional<Wrapped> {
        self.key = key
        self.defaultValue = nil
        self.encoder = encoder
        self.decoder = decoder
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
