import AppKit
import SwiftUI

@MainActor
final class MenuBarController: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private weak var appState: AppState?

    func setup(appState: AppState) {
        self.appState = appState

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

        let showItem = NSMenuItem(
            title: "Show PortVoice",
            action: #selector(showPortVoice),
            keyEquivalent: ""
        )
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(NSMenuItem.separator())

        let isEnabled = appState?.isEnabled ?? true
        let toggleTitle = isEnabled ? "Disable PortVoice" : "Enable PortVoice"

        let toggleItem = NSMenuItem(
            title: toggleTitle,
            action: #selector(togglePortVoice),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit PortVoice",
            action: #selector(quitPortVoice),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func showPortVoice() {
        NSApp.activate(ignoringOtherApps: true)

        for window in NSApp.windows {
            window.makeKeyAndOrderFront(nil)
        }
    }

    @objc private func togglePortVoice() {
        guard let appState else { return }

        appState.isEnabled.toggle()
        appState.updateStatus(appState.isEnabled ? "PortVoice enabled." : "PortVoice disabled.")
        SpeechService.shared.speak(appState.isEnabled ? "PortVoice enabled" : "PortVoice disabled")

        rebuildMenu()
    }

    @objc private func quitPortVoice() {
        NSApp.terminate(nil)
    }
}
