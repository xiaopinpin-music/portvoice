import Foundation

enum NotificationMode: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case full = "Full"
    case smart = "Smart"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .standard:
            return "Standard: speak the most useful announcement."
        case .full:
            return "Full: speak every detected event."
        case .smart:
            return "Smart: wait briefly for a more specific announcement."
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isEnabled: Bool = true
    @Published var statusMessage: String = "PortVoice is ready."
    @Published var notificationMode: NotificationMode = .full

    func updateStatus(_ message: String) {
        statusMessage = message
    }
}
