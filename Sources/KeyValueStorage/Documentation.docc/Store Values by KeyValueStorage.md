# Store Values by KeyValueStorage

Learn how to store values by ``KeyValueStorage``.

## Overview
`KeyValueStorage` can store values in a type-safe manner.  
To get the advantage, some preparations are required.

1. Define keys
2. Let types conform to ``KeyValueStorageValue``.

## Define Keys
Define your keys corresponding to values you want to store, in a key group.
```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let lastLaunchDate = KeyDefinition<Date?>(key: "lastLaunchDate")
}
```

If the generics type is not non-optional type, `defaultValue` is required.
The values is used in a case where there is no value corresponding to the key.

If the type is optional value, you don't need to set the default value.  
If the default value is not set, `nil` is used in a case where there is no value corresponding to the key.

Now, you can access the values like properties of ``KeyValueStorageValue``. (It uses `@dynamicMemberLookup` internally.)

```swift
let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
let launchCount: Int = storage.launchCount
storage.launchCount = launchCount + 1
```

## Conform to KeyValueStorageValue
``KeyDefinition`` can accept types conforming ``KeyValueStorageValue``.

```swift
public final class KeyDefinition<Value: KeyValueStorageValue>: Sendable {
    // ...
}
```

### Common types
Common types that can be stored in `UserDefaults` such as `Int` and `String` conforms the protocol as default.
Array and dictionary which consists of types which can be stored in `UserDefaults` can be also stored.

```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let friendIDs = KeyDefinition<[String]>(key: "friendIDs", defaultValue: [])
}
```

### RawRepresentable types
For a type conforming to `RawRepresentable`, it's enough to let the type conform to `KeyValueStorageValue`, if the `RawValue` conforms `KeyValueStorageValue`.
```swift
struct AppKeys: KeyGroup {
    let fruit = KeyDefinition<Fruit>(key: "fruit", defaultValue: .apple)
}

enum Fruit: Int, KeyValueStorageValue {
    case apple
    case banana
    case orange
}
```

### Custom types
For your custom types, you can implement custom conversion logics.
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
```

> Note: 
If the serialized values contains values which cannot be stored in UserDefaults, the package asserts it.
Note `nil` is also not allowed to be contained in the serialized values.

## Codable Support in JSON Format
``KeyValueStorage`` can store Codable values if the key is defined with ``JSONKeyDefinition``.

```swift
struct Account: Codable {
    var name: String
    var email: String
}

struct AppKeys: KeyGroup {
    let account = JSONKeyDefinition<Account?>(key: "account")
}
```

The Codable value is stored as `Data` in JSON format.

