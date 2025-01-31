# key-value-storage
A type-safe, observable, and injectable wrapper of UserDefaults.

## Concepts
`KeyValueStorage` is developed based on the following three concepts:
1. **Type-safety:** You can read and write common types such as `Int` and `String` and your custom types in a type-safe manner.
2. **Injectable Backend:** You can easily change the backend storage where values are stored to any ` UserDefaults` or ` InMemoryStorage`.
3. **Observable Changes:** `KeyValueStorage` supports Observation, AsyncSequence, and Publisher of Combine.

## Simple Example
1. Define keys and types you want to save.

```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let lastLaunchDate = KeyDefinition<Date?>(key: "lastLaunchDate")
}
```

2. Make a storage and read / write the value by `@dynamicMemberLookup`

```swift
let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)

// Read
let launchCount = storage.launchCount 

// Write
storage.launchCount = launchCount + 1
strorage.lastLaunchDate = .now
```

## Requirements
Swift 6+

### Platforms
- iOS 17+
- macOS 14+
- watchOS 10+
- visionOS 1+
- tvOS 17+

## Installation
You can add this package by Swift Package Manager.
```swift
dependencies: [
    .package(url: "https://github.com/mtj0928/key-value-storage", from: "0.1.0")
],
targets: [
    .target(name: "YOUR_TARGETS", dependencies: [
      .product(name: "KeyValueStorage", package: "key-value-storage")
    ]),
]
```

## Type-safety
### Key Definitions
As shown in the above section, defining keys in a key group makes your code type-safe.
```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let lastLaunchDate = KeyDefinition<Date?>(key: "lastLaunchDate")
}
```

You can specify all types UserDefaults can accept to the type of `KeyDefinition`.
If you specify `Optional` to the type of KeyDefinition like `lastLaunchDate`, you can omit the default value.

And you can read and write the value.
```swift
let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
let lastLaunchDate: Int = storage.lastLaunchDate
storage.lastLaunchDate = lastLaunchDate + 1
```

### Custom Type Support
You can store and read your custom type by making the type conform to `KeyValueStorageValue`.


If your type is `RawRepresentable`, it's enough to add the conformance.
```swift
enum Fruit: Int, KeyValueStorageValue {
    case apple
    case banana
    case orange
}

struct AppKeys: KeyGroup {
    let fruit = KeyDefinition<Fruit>(key: "fruit", defaultValue: .apple)
}

let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
let fruit: Fruit = storage.fruit
```

In other cases, you can write custom serialization / deserialization logics.
```swift
struct Person: KeyValueStorageValue, Equatable {
    typealias StoredRawValue = [String: any Sendable]

    var name: String
    var age: Int

    func serialize() -> StoredRawValue {
        ["name": name, "age": age]
    }

    static func deserialize(from dictionary: StoredRawValue) -> Person? {
        guard let name = dictionary["name"] as? String,
              let age = dictionary["age"] as? Int
        else { return nil }
        return Person(name: name, age: age)
    }
}

struct AppKeys: KeyGroup {
    let person = KeyDefinition<Person?>(key: "person")
}

let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
let person: Person? = storage.person
```

### Codable Support (JSON)
Also, you can easily store your type inhering Codeable by using `JSONKeyDefinition`.

```swift
struct Account: Codable {
    var name: String
    var email: String
}

struct AppKeys: KeyGroup {
    let account = JSONKeyDefinition<Account?>(key: "account")
}

let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
let account: Account? = storage.account
```

### Key Group
`KeyGroup` is a combination of keys, and all keys in the same group are used in the same storage.

And, the group can be nested in another group.

So, for example, you can divide the keys by purpose and combine them into one group.
```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let debug = DebugKeys()
}

struct DebugKeys: KeyGroup {
    let showConsole = KeyDefinition<Bool>(key: "showConsole", defaultValue: false)
}

let standardStorage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
let launchCount = standardStorage.launchCount
let showConsole = standardStorage.debug.showConsole
```

## Injectable Backend

You can easily change the backend where values are stored to any ` UserDefaults`.
```swift
let standardStorage = KeyValueStorage<StandardKeys>(backend: UserDefaults.standard)
let appGroupStorage = KeyValueStorage<AppGroupKeys>(backend: UserDefaults(suiteName: "APP_GROUP")!)
```

`InMemoryStorage` is also available as the backend.  
This is useful when you want to run unit tests in parallel.
```swift
let standardStorage = KeyValueStorage<StandardKeys>(backend: InMemoryStorage())
```

## Observe Changes
### Observation
`KeyValueStorage` supports Observation by default.

For example, this view is automatically updated when the counter is updated.
```swift
struct Keys: KeyGroup {
    let counter = KeyDefinition(key: "counter", defaultValue: 0)
}

struct ContentView: View {
    var storage: KeyValueStorage<Keys>

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
> [!NOTE]
> Please capture the KeyValueStorage for as long as you need to observe it, because the observation is finished when the KeyValueStorage is released.

### AsyncSequence
You can observe the changes to key by `AsyncSequence`
```swift
let storage: KeyValueStorage<Keys> = ...
Task {
    for await _ in storage.stream(key: \.counter) {
        print("New value: \(storage.counter)")
    }
}
```
> [!NOTE]
> Please capture the KeyValueStorage for as long as you need to observe it, because the stream is finished when the KeyValueStorage is released.

### Combine
You can observe the changes to key by `AsyncSequence`

```swift
let storage: KeyValueStorage<Keys> = ...
storage.publishers(key: \.counter)
    .sink {
        print("New value: \(storage.counter)")
    }
```
> [!NOTE]
> Please capture the KeyValueStorage for as long as you need to observe it, because the stream is finished when the KeyValueStorage is released.
