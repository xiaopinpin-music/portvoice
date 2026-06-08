import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var runtime: AppRuntime?

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        runtime?.start()

        if LaunchMode.isBackgroundLaunch {
            // Login background launch: tinggal di menu bar saja. Tanpa
            // WindowGroup, sudah tidak ada window nyasar yang perlu disembunyikan.
            NSApp.setActivationPolicy(.accessory)
        } else {
            // Normal launch (Applications / DMG): bertindak seperti app biasa
            // dan buka dashboard, supaya pengguna — termasuk pengguna VoiceOver
            // — langsung mendarat di window nyata yang bisa difokus.
            NSApp.setActivationPolicy(.regular)
            runtime?.presentDashboard()
        }
    }
}
