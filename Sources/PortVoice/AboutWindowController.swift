import AppKit

@MainActor
final class AboutWindowController: NSObject {
    static let shared = AboutWindowController()

    private var window: NSWindow?

    private override init() {}

    func showAboutWindow() {
        if let window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 520, height: 300))

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "PortVoice")
        title.font = NSFont.boldSystemFont(ofSize: 24)
        title.isSelectable = true

        let version = NSTextField(labelWithString: "Version 0.8.0 Internal Alpha")
        version.font = NSFont.systemFont(ofSize: 14)
        version.isSelectable = true

        let creator = NSTextField(labelWithString: "Created by Xiao Pinpin")
        creator.font = NSFont.systemFont(ofSize: 14)
        creator.isSelectable = true

        let mascot = NSTextField(labelWithString: "Bekcil, the cheerful little duck helper")
        mascot.font = NSFont.systemFont(ofSize: 14)
        mascot.isSelectable = true

        let description = NSTextField(labelWithString: "Built from blind Mac user experience and designed as a universal accessibility utility for everyone.")
        description.font = NSFont.systemFont(ofSize: 14)
        description.lineBreakMode = .byWordWrapping
        description.maximumNumberOfLines = 0
        description.isSelectable = true

        let purpose = NSTextField(labelWithString: "PortVoice speaks useful device connection and disconnection events so users can know what happened without guessing.")
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
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        newWindow.title = "About PortVoice"
        newWindow.contentView = contentView
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.setAccessibilityLabel("About PortVoice")

        self.window = newWindow

        NSApp.activate(ignoringOtherApps: true)
        newWindow.makeKeyAndOrderFront(nil)
    }
}
