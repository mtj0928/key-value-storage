import Foundation

@dynamicMemberLookup
public struct KeyValueStorage<Keys: KeyGroup>: Sendable {
    let backend: any KeyValueStorageBackend
    let keys: Keys

    private init(backend: some KeyValueStorageBackend, keys: Keys) {
        self.backend = backend
        self.keys = keys
    }

    public init(backend: some KeyValueStorageBackend) {
        self.backend = backend
        self.keys = Keys()
    }

    public subscript<NestedGroup: KeyGroup>(
        dynamicMember keyPath: KeyPath<Keys, NestedGroup>
    ) -> KeyValueStorage<NestedGroup> {
        let group = keys[keyPath: keyPath]
        return KeyValueStorage<NestedGroup>(backend: backend, keys: group)
    }
}
