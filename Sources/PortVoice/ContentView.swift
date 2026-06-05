import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRuntime: AppRuntime

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PortVoice")
                .font(.largeTitle)

            Toggle("Enable PortVoice", isOn: $appState.isEnabled)
                .accessibilityLabel("Enable PortVoice")
                .onChange(of: appState.isEnabled) { _, isEnabled in
                    appRuntime.setEnabled(isEnabled)
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
            appRuntime.start()
        }
    }
}
