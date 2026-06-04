import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var usbMonitor = USBMonitor()
    @StateObject private var storageMonitor = StorageMonitor()

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
        usbMonitor.stop()
        storageMonitor.stop()
    }

    private func startUSBMonitoring() {
        usbMonitor.onUSBConnected = {
            guard appState.isEnabled else { return }
            SpeechService.shared.speak("Device connected")
            appState.updateStatus("USB device connected.")
        }

        usbMonitor.onUSBDisconnected = {
            guard appState.isEnabled else { return }
            SpeechService.shared.speak("Device disconnected")
            appState.updateStatus("USB device disconnected.")
        }

        usbMonitor.start()
    }

    private func startStorageMonitoring() {
        storageMonitor.onStorageConnected = { volumeName in
            guard appState.isEnabled else { return }
            let message = "\(volumeName) connected"
            SpeechService.shared.speak(message)
            appState.updateStatus(message)
        }

        storageMonitor.onStorageDisconnected = { volumeName in
            guard appState.isEnabled else { return }
            let message = "\(volumeName) disconnected"
            SpeechService.shared.speak(message)
            appState.updateStatus(message)
        }

        storageMonitor.start()
    }
}
