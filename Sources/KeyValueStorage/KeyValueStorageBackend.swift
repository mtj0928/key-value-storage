import Foundation

protocol KeyValueStorageBackend: Sendable {

    // MARK: - Write
    func setBool(_ value: Bool, for key: String)
    func setInt(_ value: Int, for key: String)
    func setFloat(_ value: Float, for key: String)
    func setDouble(_ value: Double, for key: String)
    func setString(_ value: String, for key: String)
    func setURL(_ value: URL, for key: String)
    func setData(_ value: Data, for key: String)

    func setArray(_ array: [KeyValueStoragePrimitiveValue], for key: String)

    // MARK: - Read
    func bool(for key: String) -> Bool
    func int(for key: String) -> Int
    func float(for key: String) -> Float
    func double(for key: String) -> Double
    func string(for key: String) -> String?
    func url(for key: String) -> URL?
    func data(for key: String) -> Data?
    func array<Element: KeyValueStorageComposableValue>(for key: String) -> [Element]?

    func has(_ key: String) -> Bool
}
