import Foundation

@MainActor
final class NotificationCoordinator: ObservableObject {
    // Generic device announcement ditahan sebentar. Kalau ternyata device itu
    // storage volume (storageConnected/Disconnected menyusul dalam jeda ini),
    // generic-nya digabung (full mode) atau dibatalkan (simple mode). Hasil:
    //  - Non-volume & HDMI: berbunyi di KEDUA mode.
    //  - Storage volume: full = "Device connected" + nama (1 kalimat, biar
    //    tidak saling potong karena SpeechService bersifat interrupt);
    //    simple = nama saja.
    private var pendingConnectTask: Task<Void, Never>?
    private var pendingDisconnectTask: Task<Void, Never>?
    private static let volumeGraceNanos: UInt64 = 1_500_000_000  // 1.5 detik

    // MARK: - Device generik (USB non-volume)

    func deviceConnected(appState: AppState) {
        guard appState.isEnabled else { return }
        pendingConnectTask?.cancel()
        pendingConnectTask = Task { @MainActor [weak self, weak appState] in
            try? await Task.sleep(nanoseconds: Self.volumeGraceNanos)
            guard !Task.isCancelled, let self, let appState, appState.isEnabled else { return }
            // Tidak ada storage menyusul -> non-volume. Bunyi di kedua mode.
            self.speak("Device connected", appState: appState)
            self.pendingConnectTask = nil
        }
    }

    func deviceDisconnected(appState: AppState) {
        guard appState.isEnabled else { return }
        pendingDisconnectTask?.cancel()
        pendingDisconnectTask = Task { @MainActor [weak self, weak appState] in
            try? await Task.sleep(nanoseconds: Self.volumeGraceNanos)
            guard !Task.isCancelled, let self, let appState, appState.isEnabled else { return }
            self.speak("Device disconnected", appState: appState)
            self.pendingDisconnectTask = nil
        }
    }

    // MARK: - Storage volume (punya nama)

    func storageConnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled else { return }
        let hadPendingDevice = pendingConnectTask != nil
        pendingConnectTask?.cancel()
        pendingConnectTask = nil

        switch appState.notificationMode {
        case .full:
            if hadPendingDevice {
                speak("Device connected. \(volumeName) connected", appState: appState)
            } else {
                speak("\(volumeName) connected", appState: appState)
            }
        case .simple:
            speak("\(volumeName) connected", appState: appState)
        }
    }

    func storageDisconnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled else { return }
        let hadPendingDevice = pendingDisconnectTask != nil
        pendingDisconnectTask?.cancel()
        pendingDisconnectTask = nil

        switch appState.notificationMode {
        case .full:
            if hadPendingDevice {
                speak("Device disconnected. \(volumeName) disconnected", appState: appState)
            } else {
                speak("\(volumeName) disconnected", appState: appState)
            }
        case .simple:
            speak("\(volumeName) disconnected", appState: appState)
        }
    }

    // MARK: - HDMI / layar eksternal (bunyi di KEDUA mode, sama)

    func displayConnected(appState: AppState) {
        guard appState.isEnabled else { return }
        speak("Display connected", appState: appState)
    }

    func displayDisconnected(appState: AppState) {
        guard appState.isEnabled else { return }
        speak("Display disconnected", appState: appState)
    }

    func cancelPendingAnnouncements() {
        pendingConnectTask?.cancel()
        pendingConnectTask = nil
        pendingDisconnectTask?.cancel()
        pendingDisconnectTask = nil
    }

    private func speak(_ message: String, appState: AppState) {
        SpeechService.shared.speak(message)
        appState.updateStatus(message)
    }
}
