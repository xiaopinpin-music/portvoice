import Foundation

@MainActor
final class USBMonitor: ObservableObject {
    @Published private(set) var isMonitoring: Bool = false

    func start() {
        isMonitoring = true
    }

    func stop() {
        isMonitoring = false
    }
}
