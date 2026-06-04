import Foundation

@MainActor
final class NotificationCoordinator: ObservableObject {
    private var pendingGenericUSBTask: Task<Void, Never>?

    func deviceConnected(appState: AppState) {
        guard appState.isEnabled else { return }

        switch appState.notificationMode {
        case .full:
            speak("USB connected", appState: appState)

        case .standard:
            speak("Device connected", appState: appState)

        case .smart:
            pendingGenericUSBTask?.cancel()
            pendingGenericUSBTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                guard !Task.isCancelled else { return }
                guard appState.isEnabled else { return }
                speak("Device connected", appState: appState)
            }
        }
    }

    func deviceDisconnected(appState: AppState) {
        guard appState.isEnabled else { return }

        switch appState.notificationMode {
        case .full:
            speak("USB disconnected", appState: appState)

        case .standard:
            speak("Device disconnected", appState: appState)

        case .smart:
            speak("Device disconnected", appState: appState)
        }
    }

    func storageConnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled else { return }

        if appState.notificationMode == .smart {
            pendingGenericUSBTask?.cancel()
            pendingGenericUSBTask = nil
        }

        speak("\(volumeName) connected", appState: appState)
    }

    func storageDisconnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled else { return }
        speak("\(volumeName) disconnected", appState: appState)
    }

    func cancelPendingAnnouncements() {
        pendingGenericUSBTask?.cancel()
        pendingGenericUSBTask = nil
    }

    private func speak(_ message: String, appState: AppState) {
        SpeechService.shared.speak(message)
        appState.updateStatus(message)
    }
}
