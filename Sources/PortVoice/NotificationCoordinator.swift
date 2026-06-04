import Foundation

@MainActor
final class NotificationCoordinator: ObservableObject {
    func deviceConnected(appState: AppState) {
        guard appState.isEnabled else { return }

        switch appState.notificationMode {
        case .simple:
            appState.updateStatus("USB device detected.")
        case .full:
            speak("USB connected", appState: appState)
        }
    }

    func deviceDisconnected(appState: AppState) {
        guard appState.isEnabled else { return }

        switch appState.notificationMode {
        case .simple:
            appState.updateStatus("USB device removed.")
        case .full:
            speak("USB disconnected", appState: appState)
        }
    }

    func storageConnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled else { return }
        speak("\(volumeName) connected", appState: appState)
    }

    func storageDisconnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled else { return }
        speak("\(volumeName) disconnected", appState: appState)
    }

    func cancelPendingAnnouncements() {
        // Reserved for future notification coordination.
    }

    private func speak(_ message: String, appState: AppState) {
        SpeechService.shared.speak(message)
        appState.updateStatus(message)
    }
}
