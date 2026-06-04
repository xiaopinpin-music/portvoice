import Foundation

@MainActor
final class NotificationCoordinator: ObservableObject {
    private var pendingGenericConnectedTask: Task<Void, Never>?
    private var pendingGenericDisconnectedTask: Task<Void, Never>?

    func deviceConnected(appState: AppState) {
        guard appState.isEnabled else { return }

        switch appState.notificationMode {
        case .full:
            speak("USB connected", appState: appState)

        case .standard:
            pendingGenericConnectedTask?.cancel()
            pendingGenericConnectedTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard !Task.isCancelled else { return }
                guard appState.isEnabled else { return }
                speak("Device connected", appState: appState)
            }

        case .smart:
            pendingGenericConnectedTask?.cancel()
            pendingGenericConnectedTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
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
            pendingGenericDisconnectedTask?.cancel()
            pendingGenericDisconnectedTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard !Task.isCancelled else { return }
                guard appState.isEnabled else { return }
                speak("Device disconnected", appState: appState)
            }

        case .smart:
            pendingGenericDisconnectedTask?.cancel()
            pendingGenericDisconnectedTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard !Task.isCancelled else { return }
                guard appState.isEnabled else { return }
                speak("Device disconnected", appState: appState)
            }
        }
    }

    func storageConnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled else { return }

        if appState.notificationMode == .standard || appState.notificationMode == .smart {
            pendingGenericConnectedTask?.cancel()
            pendingGenericConnectedTask = nil
        }

        speak("\(volumeName) connected", appState: appState)
    }

    func storageDisconnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled else { return }

        if appState.notificationMode == .standard || appState.notificationMode == .smart {
            pendingGenericDisconnectedTask?.cancel()
            pendingGenericDisconnectedTask = nil
        }

        speak("\(volumeName) disconnected", appState: appState)
    }

    func cancelPendingAnnouncements() {
        pendingGenericConnectedTask?.cancel()
        pendingGenericConnectedTask = nil

        pendingGenericDisconnectedTask?.cancel()
        pendingGenericDisconnectedTask = nil
    }

    private func speak(_ message: String, appState: AppState) {
        SpeechService.shared.speak(message)
        appState.updateStatus(message)
    }
}
