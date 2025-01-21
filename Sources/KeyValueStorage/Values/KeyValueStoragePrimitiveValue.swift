import Foundation

enum KeyValueStoragePrimitiveValue: Sendable {
    case bool(Bool)
    case int(Int)
    case float(Float)
    case double(Double)
    case string(String)
    case url(URL)
    case data(Data)
    case array([KeyValueStoragePrimitiveValue])

    var anyValue: any Sendable {
        switch self {
        case .bool(let bool): bool
        case .int(let int): int
        case .float(let float): float
        case .double(let double): double
        case .string(let string): string
        case .url(let url): url
        case .data(let data): data
        case .array(let array): array.map { $0.anyValue }
        }
    }
}
