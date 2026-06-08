import Foundation

@MainActor
final class AppRuntime: ObservableObject {
    private let appState: AppState
    private let usbMonitor = USBMonitor()
    private let storageMonitor = StorageMonitor()
    private let displayMonitor = DisplayMonitor()
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
        setupDisplayMonitoring()
        setupMenuBar()

        if appState.isEnabled {
            usbMonitor.start()
            storageMonitor.start()
            displayMonitor.start()
            appState.updateStatus("PortVoice is listening for devices.")
        } else {
            appState.updateStatus("PortVoice is disabled.")
        }
    }

    /// Tampilkan window dashboard. Dipusatkan di sini karena AppRuntime yang
    /// memegang appState; menu bar maupun jalur normal-launch memanggil ini.
    func presentDashboard() {
        DashboardWindowController.shared.showDashboard(appState: appState, appRuntime: self)
    }

    func setEnabled(_ enabled: Bool) {
        appState.isEnabled = enabled

        if enabled {
            usbMonitor.start()
            storageMonitor.start()
            displayMonitor.start()
            appState.updateStatus("PortVoice is listening for devices.")
        } else {
            notificationCoordinator.cancelPendingAnnouncements()
            usbMonitor.stop()
            storageMonitor.stop()
            displayMonitor.stop()
            appState.updateStatus("PortVoice is disabled.")
        }

        menuBarController.rebuildMenu()
    }

    func stop() {
        notificationCoordinator.cancelPendingAnnouncements()
        usbMonitor.stop()
        storageMonitor.stop()
        displayMonitor.stop()
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

    private func setupDisplayMonitoring() {
        displayMonitor.onDisplayConnected = { [weak self] in
            guard let self else { return }
            self.notificationCoordinator.displayConnected(appState: self.appState)
        }

        displayMonitor.onDisplayDisconnected = { [weak self] in
            guard let self else { return }
            self.notificationCoordinator.displayDisconnected(appState: self.appState)
        }
    }

    private func setupMenuBar() {
        menuBarController.setup(appState: appState, runtime: self)
    }
}
