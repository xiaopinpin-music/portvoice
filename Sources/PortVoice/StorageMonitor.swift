import Foundation

@MainActor
final class StorageMonitor: ObservableObject {
    @Published private(set) var isMonitoring: Bool = false

    private var knownVolumes: Set<String> = []
    private var timer: Timer?

    var onStorageConnected: ((String) -> Void)?
    var onStorageDisconnected: ((String) -> Void)?

    func start() {
        guard !isMonitoring else { return }

        knownVolumes = currentVolumeNames()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkVolumes()
            }
        }

        isMonitoring = true
    }

    func stop() {
        guard isMonitoring else { return }

        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }

    private func checkVolumes() {
        let latestVolumes = currentVolumeNames()

        let added = latestVolumes.subtracting(knownVolumes)
        let removed = knownVolumes.subtracting(latestVolumes)

        knownVolumes = latestVolumes

        for volume in added.sorted() {
            onStorageConnected?(volume)
        }

        for volume in removed.sorted() {
            onStorageDisconnected?(volume)
        }
    }

    private func currentVolumeNames() -> Set<String> {
        let volumesURL = URL(fileURLWithPath: "/Volumes", isDirectory: true)

        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: volumesURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return Set(
            urls
                .map { $0.lastPathComponent }
                .filter { !$0.isEmpty }
                .filter { $0 != "Macintosh HD" }
        )
    }
}
