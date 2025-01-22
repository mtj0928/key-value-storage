import Foundation
//
extension KeyValueStorage {
    subscript<Value: Codable>(
        dynamicMember keyPath: KeyPath<Keys, JSONKeyDefinition<Value>>
    ) -> Value {
        get {
            let definition = keys[keyPath: keyPath]
            do {
                guard let data = backend.data(for: definition.key) else {
                    return definition.defaultValue
                }
                return try definition.decoder.decode(Value.self, from: data)
            } catch {
                assertionFailure("Should not be called: \(error)")
                return definition.defaultValue
            }
        }
        nonmutating set {
            let definition = keys[keyPath: keyPath]
            do {
                let data = try definition.encoder.encode(newValue)
                return backend.setData(data, for: definition.key)
            } catch {
                assertionFailure("Should not be called: \(error)")
            }
        }
    }
}

struct JSONKeyDefinition<Value: Codable & Sendable>: Sendable {
    let key: String
    let defaultValue: Value
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(
        key: String,
        defaultValue: Value,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.encoder = encoder
        self.decoder = decoder
    }

    init<Wrapped: Codable>(
        key: String,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) where Value == Optional<Wrapped> {
        self.key = key
        self.defaultValue = nil
        self.encoder = encoder
        self.decoder = decoder
    }
}
