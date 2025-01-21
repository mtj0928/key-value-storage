import Foundation

@dynamicMemberLookup
struct KeyValueStorage<Keys: KeyGroup>: Sendable {
    private let backend: any KeyValueStorageBackend
    private let keys = Keys()

    init(backend: any KeyValueStorageBackend) {
        self.backend = backend
    }

    subscript<Value: KeyValueStorageValue>(
        dynamicMember keyPath: KeyPath<Keys, KeyDefinition<Value>>
    ) -> Value {
        get {
            let definition = keys[keyPath: keyPath]
            return Value.fetch(for: definition.key, from: backend) ?? definition.defaultValue
        }
        nonmutating set {
            let definition = keys[keyPath: keyPath]
            return newValue.store(for: definition.key, from: backend)
        }
    }
}
