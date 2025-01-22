import Testing
import Foundation
@testable import KeyValueStorage

struct KeyValueStorageTest {
    @Test(arguments: TargetBackend.allCases)
    func primitiveUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.integer == 123)
        #expect(!storage.bool)
        #expect(storage.string == nil)

        storage.integer = 456
        #expect(storage.integer == 456)

        storage.bool.toggle()
        #expect(storage.bool)

        storage.string = "foo"
        #expect(storage.string == "foo")
    }

    @Test(arguments: TargetBackend.allCases)
    func arrayUsage(_ targetBackend: TargetBackend) {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.array == [])

        storage.array.append("foo")
        #expect(storage.array == ["foo"])
    }

    @Test(arguments: TargetBackend.allCases)
    func dictionaryUsage(_ targetBackend: TargetBackend) {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.dictionary == [:])

        storage.dictionary = [
            "foo": [
                "bar": [1, 3, 5]
            ]
        ]
        storage.dictionary["piyo"] = ["baz": [2, 4, 6]]
        #expect(storage.dictionary == [
            "foo": [
                "bar": [1, 3, 5]
            ],
            "piyo": ["baz": [2, 4, 6]]
        ])
    }

    @Test(arguments: TargetBackend.allCases)
    func nestedUsage(_ targetBackend: TargetBackend) {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.group.string == nil)
        #expect(storage.group.foo == Foo())

        storage.group.string = "hello"
        #expect(storage.group.string == "hello")

        storage.group.foo.number = 123456
        #expect(storage.group.foo.number == 123456)
    }

    @Test(arguments: TargetBackend.allCases)
    func codableUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.foo == Foo())

        storage.foo = Foo(number: 123)
        #expect(storage.foo.number == 123)
        #expect(storage.foo.bool == false)
    }
}

struct TestKeys: KeyGroup {
    // Primitive
    let integer = KeyDefinition(key: "integer", defaultValue: 123)
    let double = KeyDefinition(key: "double", defaultValue: 3.14)
    let bool = KeyDefinition(key: "bool", defaultValue: false)
    let string = KeyDefinition<String?>(key: "string")
    let array = KeyDefinition<[String]>(key: "array", defaultValue: [])
    let dictionary = KeyDefinition<[String: [String: [Int]]]>(key: "dictionary", defaultValue: [:])

    // Codable
    let foo = JSONKeyDefinition(key: "foo", defaultValue: Foo())

    let group = NestedGroup()

    struct NestedGroup: KeyGroup {
        let string = KeyDefinition<String?>(key: "nested.string")
        let foo = JSONKeyDefinition(key: "nested.foo", defaultValue: Foo())
    }
}

struct Foo: Codable, Sendable, Equatable {
    var number = 100
    var bool = false
}
