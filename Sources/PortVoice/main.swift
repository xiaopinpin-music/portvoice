import AppKit

// PortVoice is an AppKit menu-bar app. It manages its own dashboard window,
// status item, and About window directly, so it uses a plain AppKit entry point
// rather than a SwiftUI App scene.
//
// A SwiftUI App with a `Settings { EmptyView() }` scene was previously used only
// to satisfy SwiftUI's "at least one Scene" rule, but that left an empty Settings
// window in the window list. When the dashboard closed (Cmd+W), AppKit could make
// that empty Settings window key, trapping keyboard/VoiceOver focus on it. With a
// pure AppKit entry point there is no stray window to fall back to.
let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.run()
