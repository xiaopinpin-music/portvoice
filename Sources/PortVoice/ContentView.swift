import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var usbMonitor = USBMonitor()
    @StateObject private var storageMonitor = StorageMonitor()
    @StateObject private var notificationCoordinator = NotificationCoordinator()
    @StateObject private var menuBarController = MenuBarController()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PortVoice")
                .font(.largeTitle)

            Toggle("Enable PortVoice", isOn: $appState.isEnabled)
                .accessibilityLabel("Enable PortVoice")
                .onChange(of: appState.isEnabled) { _, isEnabled in
                    if isEnabled {
                        startMonitoring()
                    } else {
                        stopMonitoring()
                        appState.updateStatus("PortVoice is disabled.")
                    }
                }

            Text(appState.statusMessage)
                .accessibilityLabel(appState.statusMessage)

            Picker("Notification Mode", selection: $appState.notificationMode) {
                ForEach(NotificationMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.menu)
            .accessibilityLabel("Notification Mode")
            .accessibilityHint(appState.notificationMode.description)

            Text(appState.notificationMode.description)
                .font(.caption)
                .accessibilityLabel(appState.notificationMode.description)

            Toggle("Start in background at login", isOn: $appState.startInBackgroundAtLogin)
                .accessibilityLabel("Start in background at login")
                .accessibilityHint("When enabled, PortVoice will start automatically after you log into your Mac without opening the main dashboard.")

            Button("Test Speech") {
                SpeechService.shared.speak("Device connected")
                appState.updateStatus("Test speech played.")
            }
            .accessibilityLabel("Test Speech")
        }
        .padding()
        .frame(minWidth: 420, minHeight: 220)
        .onAppear {
            startMonitoring()
        }
        .onDisappear {
            stopMonitoring()
        }
    }

    private func startMonitoring() {
        startUSBMonitoring()
        startStorageMonitoring()
        appState.updateStatus("PortVoice is listening for devices.")
    }

    private func stopMonitoring() {
        notificationCoordinator.cancelPendingAnnouncements()
        usbMonitor.stop()
        storageMonitor.stop()
    }

    private func startUSBMonitoring() {
        usbMonitor.onUSBConnected = {
            notificationCoordinator.deviceConnected(appState: appState)
        }

        usbMonitor.onUSBDisconnected = {
            notificationCoordinator.deviceDisconnected(appState: appState)
        }

        usbMonitor.start()
    }

    private func startStorageMonitoring() {
        storageMonitor.onStorageConnected = { volumeName in
            notificationCoordinator.storageConnected(volumeName, appState: appState)
        }

        storageMonitor.onStorageDisconnected = { volumeName in
            notificationCoordinator.storageDisconnected(volumeName, appState: appState)
        }

        storageMonitor.start()
        menuBarController.setup(appState: appState)
    }
}
