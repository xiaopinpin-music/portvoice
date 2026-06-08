import AppKit

/// Memantau layar eksternal (HDMI / DisplayPort / USB-C display).
/// macOS mengirim notifikasi saat konfigurasi layar berubah; kita bandingkan
/// kumpulan ID layar untuk tahu apakah ada yang BARU terpasang atau terlepas
/// (bukan sekadar ganti resolusi).
@MainActor
final class DisplayMonitor: ObservableObject {
    @Published private(set) var isMonitoring: Bool = false

    var onDisplayConnected: (() -> Void)?
    var onDisplayDisconnected: (() -> Void)?

    private var knownScreenIDs: Set<CGDirectDisplayID> = []
    private var observer: NSObjectProtocol?

    func start() {
        guard !isMonitoring else { return }

        knownScreenIDs = Self.currentScreenIDs()

        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleScreenChange()
            }
        }

        isMonitoring = true
    }

    func stop() {
        guard isMonitoring else { return }

        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }

        knownScreenIDs = []
        isMonitoring = false
    }

    private func handleScreenChange() {
        let current = Self.currentScreenIDs()
        let added = current.subtracting(knownScreenIDs)
        let removed = knownScreenIDs.subtracting(current)
        knownScreenIDs = current

        // Hanya umumkan kalau ada layar yang benar-benar baru/hilang.
        // Ganti resolusi saja tidak mengubah kumpulan ID, jadi tidak berisik.
        if !added.isEmpty {
            onDisplayConnected?()
        }
        if !removed.isEmpty {
            onDisplayDisconnected?()
        }
    }

    private static func currentScreenIDs() -> Set<CGDirectDisplayID> {
        var ids = Set<CGDirectDisplayID>()
        for screen in NSScreen.screens {
            if let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
                ids.insert(CGDirectDisplayID(number.uint32Value))
            }
        }
        return ids
    }
}
