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
        previousPoll = knownVolumes

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

    /// A volume is announced only after it has been seen in two polls in a
    /// row (and announced gone only after two polls without it). While a drive
    /// is being ejected, macOS 27 can briefly list the Mac's own system volume
    /// ("Macintosh HD") as external for about a tenth of a second; requiring
    /// two consecutive polls keeps such flickers silent. Cost: ~0.25 s.
    private var previousPoll: Set<String> = []

    private func checkVolumes() {
        let latestVolumes = currentVolumeNames()

        let added = latestVolumes.intersection(previousPoll).subtracting(knownVolumes)
        let removed = knownVolumes.subtracting(latestVolumes).subtracting(previousPoll)

        knownVolumes = knownVolumes.union(added).subtracting(removed)
        previousPoll = latestVolumes

        for volume in added.sorted() {
            onStorageConnected?(volume)
        }

        for volume in removed.sorted() {
            onStorageDisconnected?(volume)
        }
    }

    /// Volume eksternal yang terlihat pengguna. Disaring berdasarkan SIFAT
    /// volume (bukan tebak nama), supaya Bekcil hanya bunyi untuk device fisik
    /// yang masuk/keluar port — bukan volume internal Mac (Recovery, snapshot,
    /// sistem) yang kadang muncul/hilang sendiri setelah Mac lama menyala.
    ///
    /// Tidak lagi mensyaratkan removable/ejectable: sejak macOS 27, SSD/HDD
    /// USB eksternal bisa dilaporkan removable=false DAN ejectable=false,
    /// sehingga namanya tak pernah disebut. Yang menentukan sekarang: bukan
    /// internal, bukan disk sistem, lokal (bukan disk jaringan), terlihat.
    private func currentVolumeNames() -> Set<String> {
        let keys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeIsInternalKey,
            .volumeIsBrowsableKey,
            .volumeIsLocalKey,
            .volumeIsRootFileSystemKey
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

            // Kalau macOS tak yakin, anggap internal: lebih baik diam daripada
            // menyebut volume sistem.
            let isInternal = values.volumeIsInternal ?? true
            let isBrowsable = values.volumeIsBrowsable ?? true
            let isLocal = values.volumeIsLocal ?? true
            let isRoot = values.volumeIsRootFileSystem ?? false

            // Hanya volume eksternal, lokal, terlihat user, bukan disk sistem.
            // Drive eksternal selalu terpasang di bawah /Volumes; disk sistem
            // ("/" dan /System/Volumes/...) tidak pernah diumumkan.
            guard isBrowsable, isLocal, !isInternal, !isRoot,
                  url.path.hasPrefix("/Volumes/") else { continue }

            if let name = values.volumeName?.trimmingCharacters(in: .whitespacesAndNewlines),
               !name.isEmpty {
                names.insert(name)
            }
        }

        return names
    }
}
