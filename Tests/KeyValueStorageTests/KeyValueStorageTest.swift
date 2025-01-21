import Testing
import Foundation
@testable import KeyValueStorage

struct KeyValueStorageTest {
    @Test
    func basicUsage() async throws {
        let backend = InMemoryStorage()
        let storage = KeyValueStorage<Keys>(backend: backend)
        #expect(storage.number == 123)
        #expect(!storage.bool)
        #expect(storage.string == nil)

        storage.number = 456
        storage.bool.toggle()
        storage.string = "foo"

        #expect(storage.number == 456)
        #expect(storage.bool)
        #expect(storage.string == "foo")
    }

    @Test
    func codable() async throws {
        let backend = InMemoryStorage()
        let storage = KeyValueStorage<Keys>(backend: backend)
        #expect(storage.foo == nil)

        storage.foo = Foo(number: 123)

        #expect(storage.foo?.number == 123)
    }
}

struct Keys: KeyGroup {
    let number = KeyDefinition(key: "number", defaultValue: 123)
    let bool = KeyDefinition(key: "bool", defaultValue: false)
    let string = KeyDefinition<String?>(key: "string")

    let foo = KeyDefinition<Foo?>(key: "foo")
}

struct Foo: Codable, KeyValueStorageValue {
    var number = 100

    func store(for key: String, from backend: some KeyValueStorageBackend) {
        do {
            let data = try JSONEncoder().encode(self)
            backend.setData(data, for: key)
        } catch {
            fatalError("Should not be called: \(error.localizedDescription)")
        }
    }

    static func fetch(for key: String, from backend: some KeyValueStorageBackend) -> Foo? {
        guard let data = backend.data(for: key) else { return nil }
        do {
            return try JSONDecoder().decode(Foo.self, from: data)
        } catch {
            fatalError("Should not be called: \(error.localizedDescription)")
        }
    }
}
