# key-value-storage
A type-safe, injectable and type-safe wrapper of UserDefaults.

## Basic Usage
1. Define keys and types you want to save.

```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let userName = KeyDefinition<String?>(key: "userName")
}
```

2. Make a storage and read/write the properties.

```swift
let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
print(storage.launchCount) // 0
storage.launchCount += 1 // 1
```

### Codable support (JSON)

## Observer
### Observation
### AsyncSequence
### Combine


