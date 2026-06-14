import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appState: AppState?
    private var runtime: AppRuntime?

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        installMainMenu()

        // Own the core objects here, now that there is no SwiftUI App wrapper.
        let state = AppState()
        let runtime = AppRuntime(appState: state)
        self.appState = state
        self.runtime = runtime

        runtime.start()

        if LaunchMode.isBackgroundLaunch {
            // Login background launch: live in the menu bar only — no dashboard.
            NSApp.setActivationPolicy(.accessory)
        } else {
            // Normal launch (Applications / DMG): act like a regular app and open
            // the dashboard, so users — including VoiceOver users — land directly
            // on a real, focusable window.
            NSApp.setActivationPolicy(.regular)
            runtime.presentDashboard()
        }
    }

    // A standard application main menu so the familiar keyboard shortcuts work
    // whenever the dashboard is open — most importantly Close (Cmd+W), which a
    // keyboard and VoiceOver user relies on to dismiss the window. With no explicit
    // target, the window actions route through the responder chain to the key window.
    private func installMainMenu() {
        let mainMenu = NSMenu()

        // Application menu (its title shows as the app name).
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(
            withTitle: NSLocalizedString("menu.hide", comment: ""),
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h"
        )
        appMenu.addItem(.separator())
        appMenu.addItem(
            withTitle: NSLocalizedString("menu.quit", comment: ""),
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )

        // Window menu — provides Close (Cmd+W) and Minimize (Cmd+M).
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "Window")
        windowMenuItem.submenu = windowMenu
        windowMenu.addItem(
            withTitle: NSLocalizedString("menu.close", comment: ""),
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        )
        windowMenu.addItem(
            withTitle: NSLocalizedString("menu.minimize", comment: ""),
            action: #selector(NSWindow.performMiniaturize(_:)),
            keyEquivalent: "m"
        )

        NSApp.mainMenu = mainMenu
        NSApp.windowsMenu = windowMenu
    }
}
