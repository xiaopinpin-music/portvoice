import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var usbMonitor = USBMonitor()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PortVoice")
                .font(.largeTitle)

            Toggle("Enable PortVoice", isOn: $appState.isEnabled)
                .accessibilityLabel("Enable PortVoice")
                .onChange(of: appState.isEnabled) { _, isEnabled in
                    if isEnabled {
                        startUSBMonitoring()
                    } else {
                        usbMonitor.stop()
                        appState.updateStatus("PortVoice is disabled.")
                    }
                }

            Text(appState.statusMessage)
                .accessibilityLabel(appState.statusMessage)

            Button("Test Speech") {
                SpeechService.shared.speak("USB connected")
                appState.updateStatus("Test speech played.")
            }
            .accessibilityLabel("Test Speech")
        }
        .padding()
        .frame(minWidth: 420, minHeight: 220)
        .onAppear {
            startUSBMonitoring()
        }
        .onDisappear {
            usbMonitor.stop()
        }
    }

    private func startUSBMonitoring() {
        usbMonitor.onUSBConnected = {
            guard appState.isEnabled else { return }
            SpeechService.shared.speak("USB connected")
            appState.updateStatus("USB connected.")
        }

        usbMonitor.onUSBDisconnected = {
            guard appState.isEnabled else { return }
            SpeechService.shared.speak("USB disconnected")
            appState.updateStatus("USB disconnected.")
        }

        usbMonitor.start()
        appState.updateStatus("PortVoice is listening for USB devices.")
    }
}
