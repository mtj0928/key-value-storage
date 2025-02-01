# Change Backend Storage
Learn how to change backend storage.

## Overview
``KeyValueStorage`` supports changing the backend storage.
In most cases, `UserDefaults.standard` is used.
```swift
let keyValueStorage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
```

You can use other UserDefaults like one in AppGroup.

```swift
let keyValueStorage = KeyValueStorage<AppKeys>(backend: UserDefaults(suiteName: "APP_GROUP")!)
```

``InMemoryStorage`` is a storage which doesn't persist the values.
It's useful when unit tests are run in parallel.
```swift
let keyValueStorage = KeyValueStorage<AppKeys>(backend: InMemoryStorage())
```
