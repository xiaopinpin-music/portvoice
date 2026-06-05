import Foundation

enum NotificationMode: String, CaseIterable, Identifiable {
    case simple = "Simple"
    case full = "Full"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .simple:
            return "Simple: speak the most useful storage volume name when macOS provides one."
        case .full:
            return "Full: speak generic device events and storage volume names when macOS provides them."
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    private let startInBackgroundAtLoginKey = "startInBackgroundAtLogin"

    @Published var isEnabled: Bool = true
    @Published var statusMessage: String = "PortVoice is ready."
    @Published var notificationMode: NotificationMode = .simple
    @Published var startInBackgroundAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(startInBackgroundAtLogin, forKey: startInBackgroundAtLoginKey)
            LoginItemService.shared.setEnabled(startInBackgroundAtLogin)
        }
    }

    init() {
        self.startInBackgroundAtLogin = UserDefaults.standard.bool(forKey: startInBackgroundAtLoginKey)
    }

    func updateStatus(_ message: String) {
        statusMessage = message
    }
}
