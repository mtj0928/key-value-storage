# key-value-storage
A type-safe, injectable and observable wrapper of UserDefaults.

## Simple Example
1. Define keys and types you want to save.

```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
}
```

2. Make a storage and read/write the value via the auto generated property.

```swift
let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
print(storage.launchCount) // 0
storage.launchCount += 1 // 1
```

## Usages
### Key Definitions 
The following types are supported.
- Bool
- Int
- Float
- Double
- String
- URL
- Data
- Array
- Dictionary


### Codable support (JSON)

## Observe the changes
### Observation
### AsyncSequence
### Combine

