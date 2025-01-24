@preconcurrency import Combine

public typealias KeyValueStoragePublisher = AsyncPublisher<AnyPublisher<Void, Never>>
