import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PortVoice")
                .font(.largeTitle)

            Toggle("Enable PortVoice", isOn: $appState.isEnabled)
                .accessibilityLabel("Enable PortVoice")

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
    }
}
