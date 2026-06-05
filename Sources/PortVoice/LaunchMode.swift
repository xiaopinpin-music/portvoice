import Foundation

enum LaunchMode {
    static var isBackgroundLaunch: Bool {
        ProcessInfo.processInfo.arguments.contains("--background")
    }
}
