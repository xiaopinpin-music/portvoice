import Foundation

@MainActor
final class StorageMonitor: ObservableObject {
    @Published private(set) var isMonitoring: Bool = false

    private var mountedObserver: NSObjectProtocol?
    private var unmountedObserver: NSObjectProtocol?

    var onStorageConnected: (() -> Void)?
    var onStorageDisconnected: (() -> Void)?

    func start() {
        guard !isMonitoring else { return }

        mountedObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didMountNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.onStorageConnected?()
            }
        }

        unmountedObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didUnmountNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.onStorageDisconnected?()
            }
        }

        isMonitoring = true
    }

    func stop() {
        guard isMonitoring else { return }

        if let mountedObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(mountedObserver)
            self.mountedObserver = nil
        }

        if let unmountedObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(unmountedObserver)
            self.unmountedObserver = nil
        }

        isMonitoring = false
    }
}
