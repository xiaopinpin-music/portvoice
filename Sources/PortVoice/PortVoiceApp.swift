import AppKit
import SwiftUI

@main
final class PortVoiceApp: NSObject, NSApplicationDelegate {
    private let appState = AppState()
    private lazy var appRuntime = AppRuntime(appState: appState)

    func applicationDidFinishLaunching(_ notification: Notification) {
        appRuntime.start()

        if LaunchMode.isBackgroundLaunch {
            NSApp.setActivationPolicy(.accessory)
            hideAllWindowsRepeatedly()
        } else {
            NSApp.setActivationPolicy(.regular)
            showDashboard()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func showDashboard() {
        NSApp.setActivationPolicy(.regular)

        DashboardWindowController.shared.showDashboard(
            appState: appState,
            appRuntime: appRuntime
        )
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
