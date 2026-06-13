import Foundation

enum NotificationMode: String, CaseIterable, Identifiable {
    case simple = "Simple"
    case full = "Full"

    var id: String { rawValue }

    /// Localized display name — follows the Mac's language.
    var localizedName: String {
        switch self {
        case .simple: return NSLocalizedString("mode.simple", bundle: .module, comment: "")
        case .full:   return NSLocalizedString("mode.full", bundle: .module, comment: "")
        }
    }

    /// Localized one-line description of what this mode announces.
    var localizedDescription: String {
        switch self {
        case .simple: return NSLocalizedString("mode.simple.desc", bundle: .module, comment: "")
        case .full:   return NSLocalizedString("mode.full.desc", bundle: .module, comment: "")
        }
    }

    /// Backward-compatible alias.
    var description: String { localizedDescription }
}

@MainActor
final class AppState: ObservableObject {
    private let startInBackgroundAtLoginKey = "startInBackgroundAtLogin"
    private let respectDoNotDisturbKey = "respectDoNotDisturb"

    @Published var isEnabled: Bool = true
    @Published var statusMessage: String
    @Published var notificationMode: NotificationMode = .simple

    @Published var startInBackgroundAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(startInBackgroundAtLogin, forKey: startInBackgroundAtLoginKey)
            LoginItemService.shared.setEnabled(startInBackgroundAtLogin)
        }
    }

    /// When true, announcements stay silent during Do Not Disturb / Focus.
    /// Default on — the well-behaved, Apple-like choice.
    @Published var respectDoNotDisturb: Bool {
        didSet {
            UserDefaults.standard.set(respectDoNotDisturb, forKey: respectDoNotDisturbKey)
            SpeechService.shared.respectsDoNotDisturb = respectDoNotDisturb
        }
    }

    init() {
        self.startInBackgroundAtLogin = UserDefaults.standard.bool(forKey: startInBackgroundAtLoginKey)

        // Respect Do Not Disturb defaults to ON unless the user has chosen otherwise.
        let defaults = UserDefaults.standard
        if defaults.object(forKey: respectDoNotDisturbKey) == nil {
            defaults.set(true, forKey: respectDoNotDisturbKey)
        }
        self.respectDoNotDisturb = defaults.bool(forKey: respectDoNotDisturbKey)

        self.statusMessage = NSLocalizedString("status.listening", bundle: .module, comment: "")

        // Apply the stored preference to the speech engine.
        SpeechService.shared.respectsDoNotDisturb = self.respectDoNotDisturb
    }

    func updateStatus(_ message: String) {
        statusMessage = message
    }

    /// Refresh the status line to reflect whether PortVoice is currently listening.
    func refreshStatus() {
        statusMessage = NSLocalizedString(
            isEnabled ? "status.listening" : "status.off",
            bundle: .module,
            comment: ""
        )
    }
}
