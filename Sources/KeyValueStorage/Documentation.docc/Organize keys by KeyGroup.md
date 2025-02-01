# Organize keys by KeyGroup
Learn a good usage of ``KeyGroup``.

## Overview
``KeyGroup`` can have child ``KeyGroup``.
```swift
struct AppKeys: KeyGroup {
    let foo = FooKeys()
}
struct FooKeys: KeyGroup {
    let number = KeyDefinition(key: "number", defaultValue: 0)
}

let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
let fooStorage: KeyValueStorage<FooKeys> = storage.foo
let number: Int = fooStorage.number
```

This is one of unique features of this package, and there are two benefits. 
- Organize keys based on their intended purpose.
- Exclude the consideration of keys from other modules.

## Organize keys based on their intended purpose
UserDefaults are used for several purposes.
For example, it is used for production while it is used for debug.

``KeyGroup`` is helpful to organize keys based on their purposes.
```swift
struct AppKeys: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let debug = DebugKeys()
}

struct DebugKeys: KeyGroup {
    let showConsole = KeyDefinition<Bool>(key: "showConsole", defaultValue: false)
}

let storage = KeyValueStorage<AppKeys>(backend: UserDefaults.standard)
let launchCount = storage.launchCount

let debugStorage: KeyValueStorage<DebugKeys> = storage.debug
let showConsole = debugStorage.showConsole
```

### Exclude the consideration of keys from other modules.
As another benefits, it's useful in multi module environment.

Let's consider a situation of multi module environment like this.
```
App
├─ Module A
└─ Module B
    └─ Module C
```

In this situation Module B should not know what Module A uses UserDefaults. 
The structure can be expressed with `KeyGroup` like this.

```swift
// App
struct AppKeyGroup: KeyGroup {
    let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
    let moduleA = ModuleAKeyGroup()
    let moduleB = ModuleBKeyGroup()
}

// Module A
struct ModuleAKeyGroup: KeyGroup {
    let number = KeyDefinition(key: "number", defaultValue: 0)
}

// Module B
struct ModuleBKeyGroup: KeyGroup {
    let string = KeyDefinition(key: "string", defaultValue: "")
    let moduleC = ModuleCKeyGroup()
}

// Module C
struct ModuleCKeyGroup: KeyGroup {
    let bool = KeyDefinition(key: "bool", defaultValue: false)
}
```

So, what you need to operate in Module A is only `KeyValueStorage<ModuleAKeyGroup>`.
```swift
struct ModuleAView: View {
    init(storage: KeyValueStorage<ModuleAKeyGroup>) {
        // ...
    }
}
```
