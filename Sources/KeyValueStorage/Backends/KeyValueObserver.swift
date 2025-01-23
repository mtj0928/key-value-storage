import Foundation

final class KeyValueObserver: NSObject, Sendable {
    let onChange: @Sendable () -> Void

    init(onChange: @Sendable @escaping () -> Void) {
        self.onChange = onChange
        super.init()
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        onChange()
    }
}
