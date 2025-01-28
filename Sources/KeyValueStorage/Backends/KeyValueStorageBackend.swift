import Foundation

public protocol KeyValueStorageBackend: Sendable {
    func write(_ value: any Sendable, for key: String)
    func read(for key: String) -> (any Sendable)?
    func remove(for key: String)
    func has(_ key: String) -> Bool
    func reset()
    func observe(_ key: String, changes: @escaping @Sendable () -> Void) -> KeyValueObserveCancellable
}

public final class KeyValueObserveCancellable {
    var cancelHandler: (() -> Void)?

    init(cancel: @escaping () -> Void) {
        self.cancelHandler = cancel
    }

    deinit {
        cancel()
    }

    public func cancel() {
        cancelHandler?()
        cancelHandler = nil
    }
}
