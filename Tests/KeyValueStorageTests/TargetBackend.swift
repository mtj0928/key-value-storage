import KeyValueStorage
import Foundation

enum TargetBackend: CaseIterable {
    case inMemory
    case userDefaults

    func makeBackend() -> any KeyValueStorageBackend {
        switch self {
        case .inMemory:
            return InMemoryStorage()
        case .userDefaults:
            let standard = UserDefaults.standard
            standard.reset()
            return standard
        }
    }
}
