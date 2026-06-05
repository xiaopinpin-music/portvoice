import Foundation

@MainActor
final class AppRuntime: ObservableObject {
    private let appState: AppState
    private let usbMonitor = USBMonitor()
    private let storageMonitor = StorageMonitor()
    private let notificationCoordinator = NotificationCoordinator()
    private let menuBarController = MenuBarController()

    private var isStarted = false

    init(appState: AppState) {
        self.appState = appState
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true

        setupUSBMonitoring()
        setupStorageMonitoring()
        setupMenuBar()

        if appState.isEnabled {
            usbMonitor.start()
            storageMonitor.start()
            appState.updateStatus("PortVoice is listening for devices.")
        } else {
            appState.updateStatus("PortVoice is disabled.")
        }
    }

    func setEnabled(_ enabled: Bool) {
        appState.isEnabled = enabled

        if enabled {
            usbMonitor.start()
            storageMonitor.start()
            appState.updateStatus("PortVoice is listening for devices.")
        } else {
            notificationCoordinator.cancelPendingAnnouncements()
            usbMonitor.stop()
            storageMonitor.stop()
            appState.updateStatus("PortVoice is disabled.")
        }

        menuBarController.rebuildMenu()
    }

    func stop() {
        notificationCoordinator.cancelPendingAnnouncements()
        usbMonitor.stop()
        storageMonitor.stop()
        appState.updateStatus("PortVoice stopped.")
    }

    private func setupUSBMonitoring() {
        usbMonitor.onUSBConnected = { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.notificationCoordinator.deviceConnected(appState: self.appState)
            }
        }

        usbMonitor.onUSBDisconnected = { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.notificationCoordinator.deviceDisconnected(appState: self.appState)
            }
        }
    }

    private func setupStorageMonitoring() {
        storageMonitor.onStorageConnected = { [weak self] volumeName in
            Task { @MainActor in
                guard let self else { return }
                self.notificationCoordinator.storageConnected(volumeName, appState: self.appState)
            }
        }

        storageMonitor.onStorageDisconnected = { [weak self] volumeName in
            Task { @MainActor in
                guard let self else { return }
                self.notificationCoordinator.storageDisconnected(volumeName, appState: self.appState)
            }
        }
    }

    private func setupMenuBar() {
        menuBarController.setup(appState: appState, runtime: self)
    }
}
