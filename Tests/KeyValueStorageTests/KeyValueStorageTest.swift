import Combine
import Testing
import Foundation
import Observation
import os
import KeyValueStorage

@Suite(.serialized)
struct KeyValueStorageTest {

    @Test(arguments: TargetBackend.allCases)
    func primitiveUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.integer == 123)
        #expect(storage.cgfloat == 1.23)
        #expect(!storage.bool)
        #expect(storage.string == nil)
        #expect(storage.rawValueEnum == .bbb)

        storage.integer = 456
        #expect(storage.integer == 456)

        storage.bool.toggle()
        #expect(storage.bool)

        storage.cgfloat = 4.56
        #expect(storage.cgfloat == 4.56)

        storage.string = "foo"
        #expect(storage.string == "foo")

        storage.rawValueEnum = .ccc
        #expect(storage.rawValueEnum == .ccc)

        storage.string = nil
        #expect(storage.string == nil)

        let date = Date()
        #expect(storage.date != date)
        storage.date = date
        #expect(storage.date == date)
    }

    @Test(arguments: TargetBackend.allCases)
    func arrayUsage(_ targetBackend: TargetBackend) {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.array == ["aaa"])

        storage.array.append("bbb")
        #expect(storage.array == ["aaa", "bbb"])

        #expect(storage.rawValueArray == [.aaa])
        storage.rawValueArray = [.aaa, .bbb]
        #expect(storage.rawValueArray == [.aaa, .bbb])
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
    func complexDictionaryUsage(_ targetBackend: TargetBackend) {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.complexDictionary == ["A": ["B": [.aaa]]])

        storage.complexDictionary["A-1"] = ["B-1": [.bbb]]
        storage.complexDictionary["A"]?["B"] = [.aaa, .ccc]

        #expect(storage.complexDictionary == [
            "A": ["B": [.aaa, .ccc]],
            "A-1": ["B-1": [.bbb]]
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

        #expect(storage.group.groupB.string == nil)
        storage.group.groupB.string = "world"
        #expect(storage.group.groupB.string == "world")
    }

    @Test(arguments: TargetBackend.allCases)
    func codableUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.foo == Foo())

        storage.foo = Foo(number: 123)
        #expect(storage.foo.number == 123)
        #expect(!storage.foo.bool)
    }

    @Test(arguments: TargetBackend.allCases)
    func removeUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)

        let originalInteger = storage.integer
        let originalFooNumber = storage.foo.number

        storage.integer += 1
        storage.foo.number += 1

        storage.remove(key: \.integer)
        storage.remove(key: \.foo)

        #expect(storage.integer == originalInteger)
        #expect(storage.foo.number == originalFooNumber)
    }

    // MARK: - Observation

    @Test(arguments: TargetBackend.allCases)
    func observableUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)
        withObservationTracking {
            _ = storage.integer
        } onChange: {
            isCalled.withLock {
                $0 = true
            }
        }
        storage.integer += 1

        #expect(isCalled.withLock { $0 })
        #expect(storage.integer == 124)
    }

    @Test(arguments: TargetBackend.allCases)
    func jsonObservableUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)
        withObservationTracking {
            _ = storage.foo.bool
        } onChange: {
            isCalled.withLock {
                $0 = true
            }
        }
        storage.foo.number += 1

        #expect(isCalled.withLock { $0 })
        #expect(storage.foo.number == 124)
    }

    @Test(arguments: TargetBackend.allCases)
    func nestedObservableUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)
        withObservationTracking {
            _ = storage.group.string
        } onChange: {
            isCalled.withLock {
                $0 = true
            }
        }
        storage.integer += 1
        #expect(isCalled.withLock { !$0 })

        storage.group.foo.number = 123456
        #expect(isCalled.withLock { !$0 })

        storage.group.string = "hello"
        try await Task.sleep(for: .seconds(0.1))
        #expect(isCalled.withLock { $0 })
    }

    @Test(arguments: TargetBackend.allCases)
    func nestedObservableJSONUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)
        withObservationTracking {
            _ = storage.group.foo
        } onChange: {
            isCalled.withLock {
                $0 = true
            }
        }

        storage.group.foo.number = 123456
        try await Task.sleep(for: .seconds(0.5))
        #expect(isCalled.withLock { $0 })
    }

    // MARK: - Combine

    @Test(arguments: TargetBackend.allCases)
    func combineUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)

        let cancellable = storage.publisher(key: \.integer)
            .sink {
                isCalled.withLock {
                    $0 = true
                }
            }
        storage.integer += 1

        #expect(isCalled.withLock { $0 })
        #expect(storage.integer == 124)
        _ = cancellable
    }

    @Test(arguments: TargetBackend.allCases)
    func jsonCombineUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)
        let cancellable = storage.publisher(key: \.foo)
            .sink {
                isCalled.withLock {
                    $0 = true
                }
            }
        storage.foo.number += 1
        #expect(isCalled.withLock { $0 })
        _ = cancellable
    }

    @Test(arguments: TargetBackend.allCases)
    func nestedCombineUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)
        let cancellable = storage.publisher(key: \.group.string)
            .sink {
                isCalled.withLock {
                    $0 = true
                }
            }
        storage.group.string = "123"
        #expect(isCalled.withLock { $0 })
        _ = cancellable
    }

    @Test(arguments: TargetBackend.allCases)
    func nestedCombineJSONUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)
        let cancellable = storage.publisher(key: \.group.foo)
            .sink {
                isCalled.withLock {
                    $0 = true
                }
            }
        storage.group.foo.number = 123456
        #expect(isCalled.withLock { $0 })
        _ = cancellable
    }

    // MARK: - AsyncSequence

    @Test(arguments: TargetBackend.allCases)
    func asyncSequenceUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)

        let task = Task {
            for await _ in storage.stream(key: \.integer) {
                isCalled.withLock { $0 = true }
                return
            }
        }
        try await Task.sleep(for: .seconds(0.1))
        storage.integer += 1

        try await Task.sleep(for: .seconds(0.1))
        #expect(isCalled.withLock { $0 })
        task.cancel()
    }

    @Test(arguments: TargetBackend.allCases)
    func asyncSequenceJSONUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)

        let task = Task {
            for await _ in storage.stream(key: \.foo) {
                isCalled.withLock { $0 = true }
                return
            }
        }
        try await Task.sleep(for: .seconds(0.1))
        storage.foo.bool = true

        try await Task.sleep(for: .seconds(0.1))
        #expect(isCalled.withLock { $0 })
        task.cancel()

    }

    @Test(arguments: TargetBackend.allCases)
    func asyncSequenceNestedUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)

        let task = Task {
            for await _ in storage.stream(key: \.group.string) {
                isCalled.withLock { $0 = true }
                return
            }
        }
        try await Task.sleep(for: .seconds(0.1))
        storage.group.string = "Hello"

        try await Task.sleep(for: .seconds(0.1))
        #expect(isCalled.withLock { $0 })
        task.cancel()
    }

    @Test(arguments: TargetBackend.allCases)
    func asyncSequenceNestedJSONUsage(_ targetBackend: TargetBackend) async throws {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        let isCalled = OSAllocatedUnfairLock(initialState: false)

        let task = Task {
            for await _ in storage.stream(key: \.group.foo) {
                isCalled.withLock { $0 = true }
                return
            }
        }
        try await Task.sleep(for: .seconds(0.1))
        storage.group.foo.number = 123456

        try await Task.sleep(for: .seconds(0.1))
        #expect(isCalled.withLock { $0 })
        task.cancel()
    }

    @Test(arguments: TargetBackend.allCases)
    func userID(_ targetBackend: TargetBackend) {
        let backend = targetBackend.makeBackend()
        let storage = KeyValueStorage<TestKeys>(backend: backend)
        #expect(storage.userID == nil)

        storage.userID = "userid"
        #expect(storage.userID == "userid")
    }
}

struct TestKeys: KeyGroup {
    // Primitive
    let integer = KeyDefinition(key: "integer", defaultValue: 123)
    let double = KeyDefinition(key: "double", defaultValue: 3.14)
    let cgfloat = KeyDefinition(key: "cgfloat", defaultValue: CGFloat(1.23))
    let bool = KeyDefinition(key: "bool", defaultValue: false)
    let string = KeyDefinition<String?>(key: "string")
    let date = KeyDefinition(key: "date", defaultValue: Date())
    let array = KeyDefinition<[String]>(key: "array", defaultValue: ["aaa"])
    let dictionary = KeyDefinition<[String: [String: [Int]]]>(key: "dictionary", defaultValue: [:])

    // Codable
    let foo = JSONKeyDefinition(key: "foo", defaultValue: Foo())

    // Custom type
    let userID = KeyDefinition<UserID?>(key: "userid")

    // RawValue
    let rawValueEnum = KeyDefinition(key: "rawValueEnum", defaultValue: RawValueEnum.bbb)
    let rawValueArray = KeyDefinition<[RawValueEnum]>(key: "rawValueArray", defaultValue: [.aaa])

    let complexDictionary = KeyDefinition<[String: [String: [RawValueEnum]]]>(key: "complexDictionary", defaultValue: [
        "A" : ["B": [.aaa]]
    ])

    // Nested group
    let group = NestedGroupA()

    struct NestedGroupA: KeyGroup {
        let string = KeyDefinition<String?>(key: "nested_A_string")
        let foo = JSONKeyDefinition(key: "nested_foo", defaultValue: Foo())
        let groupB = NestedGroupB()
    }

    struct NestedGroupB: KeyGroup {
        let string = KeyDefinition<String?>(key: "nested_B_string")
    }
}

struct Foo: Codable, Sendable, Equatable {
    var number = 123
    var bool = false
}

enum RawValueEnum: Int, KeyValueStorageValue {
    case aaa, bbb, ccc
}

struct UserID: ExpressibleByStringLiteral, KeyValueStorageValue, Equatable {
    typealias StoredRawValue = String
    let value: String

    init(value: String) {
        self.value = value
    }

    init(stringLiteral value: StringLiteralType) {
        self.value = value
    }

    func serialize() -> String {
        value
    }

    static func deserialize(from value: String) -> UserID? {
        UserID(value: value)
    }
}
