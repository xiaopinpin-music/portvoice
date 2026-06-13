import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var runtime: AppRuntime?

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        installMainMenu()
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

    // A standard application main menu so the familiar keyboard shortcuts work
    // whenever the dashboard is open — most importantly Close (Cmd+W), which a
    // keyboard and VoiceOver user relies on to dismiss the window. PortVoice has
    // no SwiftUI WindowGroup, so this menu is provided explicitly instead of being
    // left to SwiftUI's defaults (which do not reliably supply Close here).
    private func installMainMenu() {
        let mainMenu = NSMenu()

        // Application menu (its title shows as the app name).
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(
            withTitle: "Hide PortVoice",
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h"
        )
        appMenu.addItem(.separator())
        appMenu.addItem(
            withTitle: "Quit PortVoice",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )

        // Window menu — provides Close (Cmd+W) and Minimize (Cmd+M). With no
        // explicit target, these route through the responder chain to the key
        // window, so they act on whichever PortVoice window is focused.
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "Window")
        windowMenuItem.submenu = windowMenu
        windowMenu.addItem(
            withTitle: "Close",
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        )
        windowMenu.addItem(
            withTitle: "Minimize",
            action: #selector(NSWindow.performMiniaturize(_:)),
            keyEquivalent: "m"
        )

        NSApp.mainMenu = mainMenu
        NSApp.windowsMenu = windowMenu
    }
}
