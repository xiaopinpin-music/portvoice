import Foundation

@MainActor
final class AppRuntime: ObservableObject {
    private let appState: AppState
    private let usbMonitor = USBMonitor()
    private let storageMonitor = StorageMonitor()
    private let displayMonitor = DisplayMonitor()
    private let ethernetMonitor = EthernetMonitor()
    private let headphoneMonitor = HeadphoneMonitor()
    private let powerMonitor = PowerMonitor()
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
        setupPortMonitoring()
        setupMenuBar()

        if appState.isEnabled {
            usbMonitor.start()
            storageMonitor.start()
            displayMonitor.start()
            ethernetMonitor.start()
            headphoneMonitor.start()
            powerMonitor.start()
            appState.updateStatus(NSLocalizedString("status.listening", comment: ""))
        } else {
            appState.updateStatus(NSLocalizedString("status.off", comment: ""))
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
            ethernetMonitor.start()
            headphoneMonitor.start()
            powerMonitor.start()
            appState.updateStatus(NSLocalizedString("status.listening", comment: ""))
        } else {
            notificationCoordinator.cancelPendingAnnouncements()
            usbMonitor.stop()
            storageMonitor.stop()
            displayMonitor.stop()
            ethernetMonitor.stop()
            headphoneMonitor.stop()
            powerMonitor.stop()
            appState.updateStatus(NSLocalizedString("status.off", comment: ""))
        }

        menuBarController.rebuildMenu()
    }

    func stop() {
        notificationCoordinator.cancelPendingAnnouncements()
        usbMonitor.stop()
        storageMonitor.stop()
        displayMonitor.stop()
        ethernetMonitor.stop()
        headphoneMonitor.stop()
        powerMonitor.stop()
        appState.updateStatus(NSLocalizedString("status.stopped", comment: ""))
    }

    private func setupUSBMonitoring() {
        usbMonitor.onUSBConnected = { [weak self] identity in
            Task { @MainActor in
                guard let self else { return }
                self.notificationCoordinator.deviceConnected(identity, appState: self.appState)
            }
        }

        usbMonitor.onUSBDisconnected = { [weak self] identity in
            Task { @MainActor in
                guard let self else { return }
                self.notificationCoordinator.deviceDisconnected(identity, appState: self.appState)
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
        displayMonitor.onDisplayConnected = { [weak self] name in
            guard let self else { return }
            self.notificationCoordinator.displayConnected(name, appState: self.appState)
        }

        displayMonitor.onDisplayDisconnected = { [weak self] name in
            guard let self else { return }
            self.notificationCoordinator.displayDisconnected(name, appState: self.appState)
        }
    }

    /// Network cable, headphone jack, and MacBook charger.
    private func setupPortMonitoring() {
        ethernetMonitor.onCableConnected = { [weak self] in
            guard let self else { return }
            self.notificationCoordinator.portChanged("ethernet", connected: true, appState: self.appState)
        }
        ethernetMonitor.onCableDisconnected = { [weak self] in
            guard let self else { return }
            self.notificationCoordinator.portChanged("ethernet", connected: false, appState: self.appState)
        }
        headphoneMonitor.onHeadphonesConnected = { [weak self] in
            guard let self else { return }
            self.notificationCoordinator.portChanged("headphones", connected: true, appState: self.appState)
        }
        headphoneMonitor.onHeadphonesDisconnected = { [weak self] in
            guard let self else { return }
            self.notificationCoordinator.portChanged("headphones", connected: false, appState: self.appState)
        }
        powerMonitor.onChargerConnected = { [weak self] in
            guard let self else { return }
            self.notificationCoordinator.portChanged("charger", connected: true, appState: self.appState)
        }
        powerMonitor.onChargerDisconnected = { [weak self] in
            guard let self else { return }
            self.notificationCoordinator.portChanged("charger", connected: false, appState: self.appState)
        }
    }

    private func setupMenuBar() {
        menuBarController.setup(appState: appState, runtime: self)
    }
}
