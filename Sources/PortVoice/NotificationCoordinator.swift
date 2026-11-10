import Foundation

@MainActor
final class NotificationCoordinator: ObservableObject {
    // Aturan Dasar (Ko, 6–7 Nov 2026):
    //  - Simple: selalu "Device connected/disconnected" — tanpa nama apa pun.
    //  - Full: Bekcil "membuka paket": nama perangkat dari DeviceIdentity
    //    ("Akai MPK88 connected", "Realtek storage connected", "USB hub
    //    connected"), lalu nama drive buatan pemilik begitu macOS memasangnya.
    //    Layar: "L22e-40 display connected".
    //  - Semua yang dicolok berbunyi (hub juga) — PortVoice tidak memilih-milih.
    // Event USB ditahan 0,4 dtk (coalesce): beberapa event dari satu colokan
    // (dok, hub + isinya) diumumkan sekali, nama yang sama tidak diulang.
    // Di Full, volume yang muncul dalam jeda itu digabung jadi satu ucapan;
    // yang lebih lambat menyusul MENGANTRE (tidak memotong).
    private var pendingConnect: [DeviceIdentity] = []
    private var pendingDisconnect: [DeviceIdentity] = []
    private var pendingConnectTask: Task<Void, Never>?
    private var pendingDisconnectTask: Task<Void, Never>?
    private static let coalesceNanos: UInt64 = 400_000_000  // 0,4 detik

    // MARK: - USB

    func deviceConnected(_ identity: DeviceIdentity, appState: AppState) {
        guard appState.isEnabled else { return }
        pendingConnect.append(identity)
        pendingConnectTask?.cancel()
        pendingConnectTask = Task { @MainActor [weak self, weak appState] in
            try? await Task.sleep(nanoseconds: Self.coalesceNanos)
            guard !Task.isCancelled, let self, let appState, appState.isEnabled else { return }
            let devices = self.pendingConnect
            self.pendingConnect = []
            self.pendingConnectTask = nil
            self.speak(self.devicesSentence(devices, connected: true, mode: appState.notificationMode),
                       appState: appState)
        }
    }

    func deviceDisconnected(_ identity: DeviceIdentity, appState: AppState) {
        guard appState.isEnabled else { return }
        pendingDisconnect.append(identity)
        pendingDisconnectTask?.cancel()
        pendingDisconnectTask = Task { @MainActor [weak self, weak appState] in
            try? await Task.sleep(nanoseconds: Self.coalesceNanos)
            guard !Task.isCancelled, let self, let appState, appState.isEnabled else { return }
            let devices = self.pendingDisconnect
            self.pendingDisconnect = []
            self.pendingDisconnectTask = nil
            self.speak(self.devicesSentence(devices, connected: false, mode: appState.notificationMode),
                       appState: appState)
        }
    }

    // MARK: - Storage volume (nama drive buatan pemilik) — hanya Full

    func storageConnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled, appState.notificationMode == .full else { return }
        let volume = String(format: L("announce.volume.connected"), volumeName)
        if pendingConnectTask != nil {
            // Volume muncul dalam jeda USB: perangkat + drive dalam satu ucapan.
            pendingConnectTask?.cancel()
            pendingConnectTask = nil
            let devices = pendingConnect
            pendingConnect = []
            speak(devicesSentence(devices, connected: true, mode: .full) + ". " + volume, appState: appState)
        } else {
            speak(volume, appState: appState, queued: true)
        }
    }

    func storageDisconnected(_ volumeName: String, appState: AppState) {
        guard appState.isEnabled, appState.notificationMode == .full else { return }
        let volume = String(format: L("announce.volume.disconnected"), volumeName)
        if pendingDisconnectTask != nil {
            pendingDisconnectTask?.cancel()
            pendingDisconnectTask = nil
            let devices = pendingDisconnect
            pendingDisconnect = []
            speak(devicesSentence(devices, connected: false, mode: .full) + ". " + volume, appState: appState)
        } else {
            speak(volume, appState: appState, queued: true)
        }
    }

    // MARK: - Layar (HDMI / DisplayPort / USB-C)

    func displayConnected(_ name: String?, appState: AppState) {
        guard appState.isEnabled else { return }
        speak(displaySentence(name, connected: true, mode: appState.notificationMode), appState: appState)
    }

    func displayDisconnected(_ name: String?, appState: AppState) {
        guard appState.isEnabled else { return }
        speak(displaySentence(name, connected: false, mode: appState.notificationMode), appState: appState)
    }

    // MARK: - Kabel LAN, headphone, charger

    /// Same sentence in both modes: it names the kind of port, never a
    /// product ("Ethernet connected", "Headphones connected").
    /// `kind` is ethernet, headphones, or charger (device.kind.<kind>).
    func portChanged(_ kind: String, connected: Bool, appState: AppState) {
        guard appState.isEnabled else { return }
        let template = L(connected ? "announce.volume.connected" : "announce.volume.disconnected")
        speak(String(format: template, Self.sentenceCase(L("device.kind.\(kind)"))), appState: appState)
    }

    func cancelPendingAnnouncements() {
        pendingConnectTask?.cancel()
        pendingConnectTask = nil
        pendingDisconnectTask?.cancel()
        pendingDisconnectTask = nil
        pendingConnect = []
        pendingDisconnect = []
    }

    // MARK: - Kalimat

    /// Simple: always the generic sentence. Full: one sentence per distinct
    /// device name, in arrival order ("USB hub connected. Akai MPK88 connected").
    private func devicesSentence(_ devices: [DeviceIdentity], connected: Bool,
                                 mode: NotificationMode) -> String {
        let generic = L(connected ? "announce.device.connected" : "announce.device.disconnected")
        guard mode == .full else { return generic }
        let template = L(connected ? "announce.volume.connected" : "announce.volume.disconnected")
        var names: [String] = []
        for device in devices {
            let name = Self.sentenceCase(device.spokenName ?? L("device.kind.device"))
            if !names.contains(name) { names.append(name) }
        }
        guard !names.isEmpty else { return generic }
        return names.map { String(format: template, $0) }.joined(separator: ". ")
    }

    /// Simple: "Display connected". Full: "L22e-40 display connected", or the
    /// generic sentence when macOS gives no name.
    private func displaySentence(_ name: String?, connected: Bool, mode: NotificationMode) -> String {
        let generic = L(connected ? "announce.display.connected" : "announce.display.disconnected")
        guard mode == .full,
              let name = name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return generic
        }
        let named = String(format: L("device.vendorKind"), name, L("device.kind.display"))
        let template = L(connected ? "announce.volume.connected" : "announce.volume.disconnected")
        return String(format: template, Self.sentenceCase(named))
    }

    /// First letter upper-case, the rest untouched ("hub USB" -> "Hub USB").
    private static func sentenceCase(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }

    private func speak(_ message: String, appState: AppState, queued: Bool = false) {
        SpeechService.shared.speak(message, queued: queued)
        appState.updateStatus(message)
    }

    /// Localized string; announcements follow the Mac's language.
    private func L(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
