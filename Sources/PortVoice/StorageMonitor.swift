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

        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
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

    /// HANYA volume eksternal yang bisa dilepas (removable/ejectable) dan BUKAN
    /// internal. Disaring berdasarkan SIFAT volume (bukan tebak nama), supaya
    /// Bekcil hanya bunyi untuk device fisik yang masuk/keluar port —
    /// bukan volume internal Mac (Recovery, snapshot, sistem) yang kadang
    /// muncul/hilang sendiri setelah Mac lama menyala.
    private func currentVolumeNames() -> Set<String> {
        let keys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeIsRemovableKey,
            .volumeIsEjectableKey,
            .volumeIsInternalKey,
            .volumeIsBrowsableKey
        ]

        guard let urls = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: keys,
            options: [.skipHiddenVolumes]
        ) else {
            return []
        }

        var names = Set<String>()

        for url in urls {
            guard let values = try? url.resourceValues(forKeys: Set(keys)) else { continue }

            let isRemovable = values.volumeIsRemovable ?? false
            let isEjectable = values.volumeIsEjectable ?? false
            let isInternal = values.volumeIsInternal ?? false
            let isBrowsable = values.volumeIsBrowsable ?? true

            // Hanya device eksternal yang bisa dilepas, bukan internal, dan
            // terlihat user. Internal (Recovery/snapshot/boot) langsung lewat.
            guard isBrowsable, !isInternal, (isRemovable || isEjectable) else { continue }

            if let name = values.volumeName?.trimmingCharacters(in: .whitespacesAndNewlines),
               !name.isEmpty {
                names.insert(name)
            }
        }

        return names
    }
}
