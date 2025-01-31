/// A group combining keys.
///
/// ```swift
/// struct AppKeys: KeyGroup {
///     let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
///     let lastLaunchDate = KeyDefinition<Date?>(key: "lastLaunchDate")
/// }
/// ```
///
/// The group can be nested,
/// ```swift
/// struct AppKeys: KeyGroup {
///     let launchCount = KeyDefinition(key: "launchCount", defaultValue: 0)
///     let debug = DebugKeys()
/// }
///
/// struct DebugKeys: KeyGroup {
///     let showConsole = KeyDefinition<Bool>(key: "showConsole", defaultValue: false)
/// }
/// ```
public protocol KeyGroup: Sendable {
    init()
}
