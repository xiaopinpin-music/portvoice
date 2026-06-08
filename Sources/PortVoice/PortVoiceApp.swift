import SwiftUI

@main
struct PortVoiceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var appState: AppState
    @StateObject private var appRuntime: AppRuntime

    init() {
        let state = AppState()
        let runtime = AppRuntime(appState: state)

        _appState = StateObject(wrappedValue: state)
        _appRuntime = StateObject(wrappedValue: runtime)

        appDelegate.appState = state
        appDelegate.runtime = runtime
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
