import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var isEnabled: Bool = true
    @Published var statusMessage: String = "PortVoice is ready."

    func updateStatus(_ message: String) {
        statusMessage = message
    }
}
