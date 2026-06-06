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

    private func currentVolumeNames() -> Set<String> {
        let volumesURL = URL(fileURLWithPath: "/Volumes", isDirectory: true)

        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: volumesURL,
            includingPropertiesForKeys: [.isVolumeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return Set(
            urls
                .map { $0.lastPathComponent }
                .filter { shouldAnnounceVolume($0) }
        )
    }

    private func shouldAnnounceVolume(_ name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else { return false }

        let ignoredNames: Set<String> = [
            "Macintosh HD",
            "Recovery",
            "Preboot",
            "VM",
            "Update",
            "com.apple.TimeMachine.localsnapshots"
        ]

        if ignoredNames.contains(trimmedName) {
            return false
        }

        let ignoredWords = [
            "Recovery",
            "Preboot",
            "VM",
            "Update",
            "Snapshot",
            "TimeMachine",
            "MobileBackups",
            "com.apple"
        ]

        for word in ignoredWords {
            if trimmedName.localizedCaseInsensitiveContains(word) {
                return false
            }
        }

        if looksLikeTechnicalIdentifier(trimmedName) {
            return false
        }

        return true
    }

    private func looksLikeTechnicalIdentifier(_ name: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "0123456789abcdefABCDEF-")
        let characterSet = CharacterSet(charactersIn: name)

        let onlyHexLikeCharacters = characterSet.isSubset(of: allowed)
        let hasHyphen = name.contains("-")
        let isLong = name.count >= 16

        if onlyHexLikeCharacters && isLong {
            return true
        }

        if hasHyphen && name.count >= 24 {
            return true
        }

        let digitCount = name.filter { $0.isNumber }.count

        if name.count >= 12 && digitCount >= 8 {
            return true
        }

        return false
    }
}
