import AppKit

@MainActor
final class AboutWindowController: NSObject, NSWindowDelegate {
    static let shared = AboutWindowController()

    private var window: NSWindow?

    private override init() {}

    func showAboutWindow() {
        // Jadi .regular dulu supaya menu bar atas (dengan perintah Close/Cmd+W)
        // aktif — kalau tidak, Cmd+W tidak nyambung saat app dari background.
        NSApp.setActivationPolicy(.regular)

        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 520, height: 300))

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        // "PortVoice" is the brand name and stays the same in every language.
        let title = NSTextField(labelWithString: "PortVoice")
        title.font = NSFont.boldSystemFont(ofSize: 24)
        title.isSelectable = true

        let version = NSTextField(
            labelWithString: String(format: NSLocalizedString("about.version", comment: ""), "0.9.0")
        )
        version.font = NSFont.systemFont(ofSize: 14)
        version.isSelectable = true

        let creator = NSTextField(labelWithString: NSLocalizedString("about.creator", comment: ""))
        creator.font = NSFont.systemFont(ofSize: 14)
        creator.isSelectable = true

        let mascot = NSTextField(labelWithString: NSLocalizedString("about.mascot", comment: ""))
        mascot.font = NSFont.systemFont(ofSize: 14)
        mascot.isSelectable = true

        let description = NSTextField(labelWithString: NSLocalizedString("about.description", comment: ""))
        description.font = NSFont.systemFont(ofSize: 14)
        description.lineBreakMode = .byWordWrapping
        description.maximumNumberOfLines = 0
        description.isSelectable = true

        let purpose = NSTextField(labelWithString: NSLocalizedString("about.purpose", comment: ""))
        purpose.font = NSFont.systemFont(ofSize: 14)
        purpose.lineBreakMode = .byWordWrapping
        purpose.maximumNumberOfLines = 0
        purpose.isSelectable = true

        for view in [title, version, creator, mascot, description, purpose] {
            stack.addArrangedSubview(view)
        }

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        newWindow.title = NSLocalizedString("menu.about", comment: "")
        newWindow.contentView = contentView
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.setAccessibilityLabel(NSLocalizedString("menu.about", comment: ""))
        newWindow.delegate = self

        self.window = newWindow

        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // Cmd+W / tombol close: tutup window Help/About, app kembali ke background
    // (menu bar saja) — sama seperti dashboard.
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
