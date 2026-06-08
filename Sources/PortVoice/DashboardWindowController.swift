import AppKit
import SwiftUI

@MainActor
final class DashboardWindowController: NSObject {
    static let shared = DashboardWindowController()

    private var window: NSWindow?

    private override init() {}

    func showDashboard(appState: AppState, appRuntime: AppRuntime) {
        NSApp.setActivationPolicy(.regular)

        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = ContentView()
            .environmentObject(appState)
            .environmentObject(appRuntime)

        let hostingController = NSHostingController(rootView: contentView)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 360),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        newWindow.title = "PortVoice"
        newWindow.contentViewController = hostingController
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.setAccessibilityLabel("PortVoice Dashboard")

        self.window = newWindow

        // VoiceOver mendarat dengan andal kalau window jadi KEY dulu, baru
        // app diaktifkan. Mengaktifkan app sebelum window ada/jadi-key adalah
        // bagian dari kegagalan fokus "tung tung" yang lama.
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hideDashboard() {
        window?.orderOut(nil)
    }
}
