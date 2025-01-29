# key-value-storage
A type-safe, observable, and injectable wrapper of UserDefaults.

## Simple Example
1. Define keys and types you want to save.

```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let lastLaunchDate = KeyDefinition<Date?>(key: "lastLaunchDate")
}
```

2. Make a storage and read/write the value via the auto generated property.

```swift
let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)

// Read
let launchCount = storage.launchCount 

// Write
storage.launchCount = launchCount + 1
strorage.lastLaunchDate = .now
```

## Usages
### Key Definitions
As shown in the above section, defining keys in a key group makes your code type-safe.
```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let lastLaunchDate = KeyDefinition<Date?>(key: "lastLaunchDate")
}
```

You can specify all types UserDefaults can accept to the type of `KeyDefinition`.

If you specify `Optional` to the type of KeyDefinition like `lastLaunchDate`, you can emit the default value.

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
storage.fruit = .banana
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
storage.person = Person(name: "foo", age: 20)   
```

### Codable support (JSON)
Also, you can easily store your custom type by using `JSONKeyDefinition`

### Key Group

## Observe the changes
### Observation
### AsyncSequence
### Combine
