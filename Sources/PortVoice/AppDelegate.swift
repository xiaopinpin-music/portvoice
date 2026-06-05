import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var runtime: AppRuntime?

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        runtime?.start()

        if LaunchMode.isBackgroundLaunch {
            NSApp.setActivationPolicy(.accessory)
            hideAllWindowsRepeatedly()
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if LaunchMode.isBackgroundLaunch {
            hideAllWindowsRepeatedly()
        }
    }

    private func hideAllWindowsRepeatedly() {
        hideAllWindows()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.hideAllWindows()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.hideAllWindows()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.hideAllWindows()
        }
    }

    private func hideAllWindows() {
        for window in NSApp.windows {
            window.orderOut(nil)
        }
    }
}
