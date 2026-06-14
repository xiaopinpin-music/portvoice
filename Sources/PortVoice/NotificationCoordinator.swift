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
    // Teks pengumuman dilokalkan: ikut bahasa Mac otomatis (en/id, dst).
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
            self.speak(L("announce.device.connected"), appState: appState)
            self.pendingConnectTask = nil
        }
    }

    func deviceDisconnected(appState: AppState) {
        guard appState.isEnabled else { return }
        pendingDisconnectTask?.cancel()
        pendingDisconnectTask = Task { @MainActor [weak self, weak appState] in
            try? await Task.sleep(nanoseconds: Self.volumeGraceNanos)
            guard !Task.isCancelled, let self, let appState, appState.isEnabled else { return }
            self.speak(L("announce.device.disconnected"), appState: appState)
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
                speak(String(format: L("announce.deviceThenVolume.connected"), volumeName), appState: appState)
            } else {
                speak(String(format: L("announce.volume.connected"), volumeName), appState: appState)
            }
        case .simple:
            speak(String(format: L("announce.volume.connected"), volumeName), appState: appState)
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
                speak(String(format: L("announce.deviceThenVolume.disconnected"), volumeName), appState: appState)
            } else {
                speak(String(format: L("announce.volume.disconnected"), volumeName), appState: appState)
            }
        case .simple:
            speak(String(format: L("announce.volume.disconnected"), volumeName), appState: appState)
        }
    }

    // MARK: - HDMI / layar eksternal (bunyi di KEDUA mode, sama)

    func displayConnected(appState: AppState) {
        guard appState.isEnabled else { return }
        speak(L("announce.display.connected"), appState: appState)
    }

    func displayDisconnected(appState: AppState) {
        guard appState.isEnabled else { return }
        speak(L("announce.display.disconnected"), appState: appState)
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

    /// Localized string from the package resource bundle. SPM places localized
    /// loaded from the main app bundle, so announcements follow the Mac's language.
    private func L(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
