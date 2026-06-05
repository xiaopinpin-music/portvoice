import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)

        if LaunchMode.isBackgroundLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for window in NSApp.windows {
                    window.orderOut(nil)
                }
            }
        }
    }
}
