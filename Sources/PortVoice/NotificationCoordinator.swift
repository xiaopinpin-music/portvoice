import Foundation

@MainActor
final class NotificationCoordinator: ObservableObject {
    // Mode (keputusan Ko, 6 Nov 2026):
    //  - Simple: hanya "Device connected/disconnected" — tanpa nama drive.
    //    Untuk yang tak mau ramai.
    //  - Full: "Device connected" + nama drive begitu macOS memasangnya.
    //  - Layar/HDMI: berbunyi sama di kedua mode.
    // Event USB generik ditahan sebentar (coalesce) supaya satu perangkat yang
    // muncul sebagai beberapa event USB cukup diumumkan sekali. Di Full, kalau
    // volume muncul dalam jeda itu, keduanya digabung jadi satu kalimat; kalau
    // lebih lambat, nama drive menyusul MENGANTRE (tidak memotong).
    // Teks pengumuman dilokalkan: ikut bahasa Mac otomatis.
    private var pendingConnectTask: Task<Void, Never>?
    private var pendingDisconnectTask: Task<Void, Never>?
    private static let coalesceNanos: UInt64 = 400_000_000  // 0,4 detik (dulu 1,5)

    // MARK: - Device generik (USB non-volume)

    func deviceConnected(appState: AppState) {
        guard appState.isEnabled else { return }
        pendingConnectTask?.cancel()
        pendingConnectTask = Task { @MainActor [weak self, weak appState] in
            try? await Task.sleep(nanoseconds: Self.coalesceNanos)
            guard !Task.isCancelled, let self, let appState, appState.isEnabled else { return }
            self.speak(L("announce.device.connected"), appState: appState)
            self.pendingConnectTask = nil
        }
    }

    func deviceDisconnected(appState: AppState) {
        guard appState.isEnabled else { return }
        pendingDisconnectTask?.cancel()
        pendingDisconnectTask = Task { @MainActor [weak self, weak appState] in
            try? await Task.sleep(nanoseconds: Self.coalesceNanos)
            guard !Task.isCancelled, let self, let appState, appState.isEnabled else { return }
            self.speak(L("announce.device.disconnected"), appState: appState)
            self.pendingDisconnectTask = nil
        }
    }

    // MARK: - Storage volume (punya nama) — hanya Full

    func storageConnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled, appState.notificationMode == .full else { return }
        if pendingConnectTask != nil {
            // Volume muncul dalam jeda USB: satu kalimat utuh.
            pendingConnectTask?.cancel()
            pendingConnectTask = nil
            speak(String(format: L("announce.deviceThenVolume.connected"), volumeName), appState: appState)
        } else {
            // "Device connected" sudah/akan terucap: nama menyusul, mengantre.
            speak(String(format: L("announce.volume.connected"), volumeName), appState: appState, queued: true)
        }
    }

    func storageDisconnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled, appState.notificationMode == .full else { return }
        if pendingDisconnectTask != nil {
            pendingDisconnectTask?.cancel()
            pendingDisconnectTask = nil
            speak(String(format: L("announce.deviceThenVolume.disconnected"), volumeName), appState: appState)
        } else {
            speak(String(format: L("announce.volume.disconnected"), volumeName), appState: appState, queued: true)
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

    private func speak(_ message: String, appState: AppState, queued: Bool = false) {
        SpeechService.shared.speak(message, queued: queued)
        appState.updateStatus(message)
    }

    /// Localized string from the package resource bundle. SPM places localized
    /// loaded from the main app bundle, so announcements follow the Mac's language.
    private func L(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
