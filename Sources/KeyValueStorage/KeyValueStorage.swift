import Foundation

/// A key value storage.
///
/// This storage supports @dynamicMemberLookup, and you can access the key such as its property.
/// ```swift
/// let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
/// let lastLaunchDate: Int = storage.lastLaunchDate
/// storage.lastLaunchDate = lastLaunchDate + 1
/// ```
///
/// `KeyValueStorage` supports Observation by default, so your view can reflect the latest values when the values are updated.
/// ```swift
/// struct ContentView: View {
///     var storage: KeyValueStorage<AppKeys>
///     var body: some View {
///        VStack {
///            Text("\(storage.counter)")
///            Button("add") {
///                storage.counter += 1
///            }
///        }
///    }
/// }
/// ```
///
/// > NOTE:
/// Keep this storage for as long as long you need to observe the values, because the observation is cancelled when the storage is released.
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
