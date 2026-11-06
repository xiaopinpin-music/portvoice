import AppKit

/// Memantau layar eksternal (HDMI / DisplayPort / USB-C display).
/// macOS mengirim notifikasi saat konfigurasi layar berubah; kita bandingkan
/// kumpulan ID layar untuk tahu apakah ada yang BARU terpasang atau terlepas
/// (bukan sekadar ganti resolusi).
@MainActor
final class DisplayMonitor: ObservableObject {
    @Published private(set) var isMonitoring: Bool = false

    /// The display's own name as macOS reports it (for example "L22e-40"),
    /// or nil when unknown.
    var onDisplayConnected: ((String?) -> Void)?
    var onDisplayDisconnected: ((String?) -> Void)?

    private var knownScreens: [CGDirectDisplayID: String] = [:]
    private var observer: NSObjectProtocol?

    func start() {
        guard !isMonitoring else { return }

        knownScreens = Self.currentScreens()

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

        knownScreens = [:]
        isMonitoring = false
    }

    private func handleScreenChange() {
        let current = Self.currentScreens()
        let added = Set(current.keys).subtracting(knownScreens.keys)
        let removed = Set(knownScreens.keys).subtracting(current.keys)
        let previous = knownScreens
        knownScreens = current

        // Hanya umumkan kalau ada layar yang benar-benar baru/hilang.
        // Ganti resolusi saja tidak mengubah kumpulan ID, jadi tidak berisik.
        // Nama layar yang hilang diambil dari ingatan (layarnya sudah pergi).
        for id in added.sorted() {
            onDisplayConnected?(current[id])
        }
        for id in removed.sorted() {
            onDisplayDisconnected?(previous[id])
        }
    }

    private static func currentScreens() -> [CGDirectDisplayID: String] {
        var screens: [CGDirectDisplayID: String] = [:]
        for screen in NSScreen.screens {
            if let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
                screens[CGDirectDisplayID(number.uint32Value)] = screen.localizedName
            }
        }
        return screens
    }
}
