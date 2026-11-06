import Foundation

enum NotificationMode: String, CaseIterable, Identifiable {
    case simple = "Simple"
    case full = "Full"

    var id: String { rawValue }

    /// Localized display name — follows the Mac's language.
    var localizedName: String {
        switch self {
        case .simple: return NSLocalizedString("mode.simple", comment: "")
        case .full:   return NSLocalizedString("mode.full", comment: "")
        }
    }

    /// Localized one-line description of what this mode announces.
    var localizedDescription: String {
        switch self {
        case .simple: return NSLocalizedString("mode.simple.desc", comment: "")
        case .full:   return NSLocalizedString("mode.full.desc", comment: "")
        }
    }

    /// Backward-compatible alias.
    var description: String { localizedDescription }
}

@MainActor
final class AppState: ObservableObject {
    private let startInBackgroundAtLoginKey = "startInBackgroundAtLogin"
    private let respectDoNotDisturbKey = "respectDoNotDisturb"
    private let notificationModeKey = "notificationMode"

    /// Deliberately NOT persisted: after a restart PortVoice always listens
    /// again, so a blind user is never left with a silent app by accident.
    @Published var isEnabled: Bool = true
    @Published var statusMessage: String

    /// Simple or Full. Persisted, so the user's choice survives quitting
    /// PortVoice and restarting the Mac.
    @Published var notificationMode: NotificationMode {
        didSet {
            UserDefaults.standard.set(notificationMode.rawValue, forKey: notificationModeKey)
        }
    }

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

        // Restore the user's mode. A first install starts in Full, so new users
        // hear everything PortVoice can say (drive names included); anyone who
        // finds it too busy can switch to Simple, and that choice is kept.
        self.notificationMode = UserDefaults.standard.string(forKey: notificationModeKey)
            .flatMap(NotificationMode.init(rawValue:)) ?? .full

        // Respect Do Not Disturb defaults to ON unless the user has chosen otherwise.
        let defaults = UserDefaults.standard
        if defaults.object(forKey: respectDoNotDisturbKey) == nil {
            defaults.set(true, forKey: respectDoNotDisturbKey)
        }
        self.respectDoNotDisturb = defaults.bool(forKey: respectDoNotDisturbKey)

        self.statusMessage = NSLocalizedString("status.listening", comment: "")

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
            comment: ""
        )
    }
}
