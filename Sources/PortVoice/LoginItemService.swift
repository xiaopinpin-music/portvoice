import Foundation
import ServiceManagement

@MainActor
final class LoginItemService {
    static let shared = LoginItemService()

    private init() {}

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("PortVoice login item error: \(error.localizedDescription)")
        }
    }
}
