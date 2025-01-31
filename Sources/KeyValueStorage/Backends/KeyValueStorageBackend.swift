import Foundation

/// A backend of ``KeyValueStorage``.
public protocol KeyValueStorageBackend: Sendable {
    /// Write the value  corresponding to the given key.
    /// The function accept types that the actual backend can accept.
    func write(_ value: any Sendable, for key: String)

    /// Read the value corresponding to the given key.
    /// If there is no value, `nil` is returned.
    func read(for key: String) -> (any Sendable)?

    /// Remove the value corresponding to the given key.
    func remove(for key: String)

    /// Returns a bool value indicating whether a value corresponding to the key exist or not.
    func has(_ key: String) -> Bool

    /// Resets the storage.
    func reset()

    /// Observes the changes of the value corresponding to the given key.
    /// `onChange` closure is called when the value is changed.
    ///
    /// The function returns ``KeyValueObserveCancellable`` which can cancel the observe.
    func observe(_ key: String, onChange: @escaping @Sendable () -> Void) -> KeyValueObserveCancellable
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
