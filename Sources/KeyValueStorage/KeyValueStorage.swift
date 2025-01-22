import Foundation

@dynamicMemberLookup
struct KeyValueStorage<Keys: KeyGroup>: Sendable {
    public let backend: any KeyValueStorageBackend
    public let keys: Keys

    private init(backend: some KeyValueStorageBackend, keys: Keys) {
        self.backend = backend
        self.keys = Keys()
    }

    init(backend: some KeyValueStorageBackend) {
        self.backend = backend
        self.keys = Keys()
    }

    subscript<NestedGroup: KeyGroup>(
        dynamicMember keyPath: KeyPath<Keys, NestedGroup>
    ) -> KeyValueStorage<NestedGroup> {
        let group = keys[keyPath: keyPath]
        return KeyValueStorage<NestedGroup>(backend: backend, keys: group)
    }
}
