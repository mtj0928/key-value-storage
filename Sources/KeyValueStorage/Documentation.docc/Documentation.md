# ``KeyValueStorage``

A type-safe, injectable and observable wrapper of UserDefaults.

## Overview

`KeyValueStorage` is developed based on the following three concepts:
1. **Type-safety:** You can read and write common types such as `Int` and `String` and your custom types in a type-safe manner.
2. **Injectable Backend:** You can easily change the backend storage where values are stored to any ` UserDefaults` or ` InMemoryStorage`.
3. **Observable Changes:** `KeyValueStorage` supports Observation, AsyncSequence, and Publisher of Combine.

### Example
First, define your keys corresponding to values you want to read and write.
```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let lastLaunchDate = KeyDefinition<Date?>(key: "lastLaunchDate")
}
```

And then, make `KeyValueStorage` and read / write the values by @dynamicMemberLookup.
```swift
let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
let launchCount: Int = storage.launchCount
storage.launchCount = launchCount + 1
```

`KeyValueStorage` supports Observation by default, so your view can reflect the latest values when the values are updated.

```swift
struct ContentView: View {
    var storage: KeyValueStorage<AppKeys>

    var body: some View {
        VStack {
            Text("\(storage.counter)")
            Button("add") {
                storage.counter += 1
            }
        }
    }
}
```

## Topics 
### Essentials
- ``KeyValueStorage``

### Key Definitions
- ``KeyGroup``
- ``KeyDefinition``
- ``KeyValueStorageValue``
- ``JSONKeyDefinition``

### Backend
- ``KeyValueStorageBackend``
- ``InMemoryStorage``

### Observation
- ``KeyValueObserveCancellable``
- ``KeyValueStoragePublisher``
