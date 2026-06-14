import AppKit
import SwiftUI

@MainActor
final class MenuBarController: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private weak var appState: AppState?
    private weak var runtime: AppRuntime?

    func setup(appState: AppState, runtime: AppRuntime) {
        self.appState = appState
        self.runtime = runtime

        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        }

        if let button = statusItem?.button {
            button.title = "PortVoice"
            button.toolTip = "PortVoice"
            button.setAccessibilityLabel("PortVoice")
        }

        rebuildMenu()
    }

    func rebuildMenu() {
        let menu = NSMenu()

        let aboutItem = NSMenuItem(
            title: NSLocalizedString("menu.about", comment: ""),
            action: #selector(showAboutPortVoice),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        let showItem = NSMenuItem(
            title: NSLocalizedString("menu.show", comment: ""),
            action: #selector(showPortVoice),
            keyEquivalent: ""
        )
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(NSMenuItem.separator())

        let isEnabled = appState?.isEnabled ?? true
        let toggleTitle = isEnabled ? NSLocalizedString("menu.disable", comment: "") : NSLocalizedString("menu.enable", comment: "")

        let toggleItem = NSMenuItem(
            title: toggleTitle,
            action: #selector(togglePortVoice),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: NSLocalizedString("menu.quit", comment: ""),
            action: #selector(quitPortVoice),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func showAboutPortVoice() {
        AboutWindowController.shared.showAboutWindow()
    }

    @objc private func showPortVoice() {
        guard let appState, let runtime else { return }

        DashboardWindowController.shared.showDashboard(
            appState: appState,
            appRuntime: runtime
        )
    }

    @objc private func togglePortVoice() {
        guard let appState else { return }

        let newValue = !appState.isEnabled
        runtime?.setEnabled(newValue)

        SpeechService.shared.speak(newValue ? NSLocalizedString("speech.enabled", comment: "") : NSLocalizedString("speech.disabled", comment: ""))

        rebuildMenu()
    }

    @objc private func quitPortVoice() {
        runtime?.stop()
        NSApp.terminate(nil)
    }
}
