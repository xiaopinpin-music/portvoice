import Foundation

enum NotificationMode: String, CaseIterable, Identifiable {
    case simple = "Simple"
    case full = "Full"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .simple:
            return "Simple: speak the most useful device name when available."
        case .full:
            return "Full: speak every detected event."
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isEnabled: Bool = true
    @Published var statusMessage: String = "PortVoice is ready."
    @Published var notificationMode: NotificationMode = .simple
    @Published var startInBackgroundAtLogin: Bool = false

    func updateStatus(_ message: String) {
        statusMessage = message
    }
}
