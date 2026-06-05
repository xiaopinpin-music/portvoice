import SwiftUI

@main
struct PortVoiceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var appState: AppState
    @StateObject private var appRuntime: AppRuntime

    init() {
        let state = AppState()
        _appState = StateObject(wrappedValue: state)
        _appRuntime = StateObject(wrappedValue: AppRuntime(appState: state))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appRuntime)
                .onAppear {
                    appRuntime.start()
                }
        }
        .windowResizability(.contentSize)
    }
}
