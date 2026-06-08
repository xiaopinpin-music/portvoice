import Foundation

@MainActor
final class NotificationCoordinator: ObservableObject {
    func deviceConnected(appState: AppState) {
        guard appState.isEnabled else { return }

        switch appState.notificationMode {
        case .simple:
            appState.updateStatus("Device detected.")
        case .full:
            speak("Device connected", appState: appState)
        }
    }

    func deviceDisconnected(appState: AppState) {
        guard appState.isEnabled else { return }

        switch appState.notificationMode {
        case .simple:
            appState.updateStatus("Device removed.")
        case .full:
            speak("Device disconnected", appState: appState)
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

    // HDMI / layar eksternal. macOS melaporkan event layar terpasang/terlepas
    // tapi tidak selalu bisa bedakan HDMI vs DisplayPort vs USB-C, jadi pakai
    // kata umum "Display" yang selalu benar (sudah mencakup HDMI).
    func displayConnected(appState: AppState) {
        guard appState.isEnabled else { return }
        speak("Display connected", appState: appState)
    }

    func displayDisconnected(appState: AppState) {
        guard appState.isEnabled else { return }
        speak("Display disconnected", appState: appState)
    }

    func cancelPendingAnnouncements() {
        // Reserved for future notification coordination.
    }

    private func speak(_ message: String, appState: AppState) {
        SpeechService.shared.speak(message)
        appState.updateStatus(message)
    }
}
