import Foundation

@MainActor
final class LoginItemService {
    static let shared = LoginItemService()

    private let label = "com.xiaopinpinmusic.portvoice.login"
    private let appExecutablePath = "/Applications/PortVoice.app/Contents/MacOS/PortVoice"

    private var launchAgentPath: URL {
        FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.xiaopinpinmusic.portvoice.login.plist")
    }

    private init() {}

    func setEnabled(_ enabled: Bool) {
        if enabled {
            installLaunchAgent()
        } else {
            removeLaunchAgent()
        }
    }

    private func installLaunchAgent() {
        let launchAgentsDirectory = launchAgentPath.deletingLastPathComponent()

        do {
            try FileManager.default.createDirectory(
                at: launchAgentsDirectory,
                withIntermediateDirectories: true
            )

            let plist = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(label)</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(appExecutablePath)</string>
                    <string>--background</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <false/>
            </dict>
            </plist>
            """

            try plist.write(to: launchAgentPath, atomically: true, encoding: .utf8)

            appLoadAgent()
        } catch {
            print("PortVoice launch agent install error: \(error.localizedDescription)")
        }
    }

    private func removeLaunchAgent() {
        appUnloadAgent()

        do {
            if FileManager.default.fileExists(atPath: launchAgentPath.path) {
                try FileManager.default.removeItem(at: launchAgentPath)
            }
        } catch {
            print("PortVoice launch agent remove error: \(error.localizedDescription)")
        }
    }

    private func appLoadAgent() {
        runLaunchctl(arguments: ["bootstrap", "gui/\(getuid())", launchAgentPath.path])
    }

    private func appUnloadAgent() {
        runLaunchctl(arguments: ["bootout", "gui/\(getuid())", launchAgentPath.path])
    }

    private func runLaunchctl(arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("PortVoice launchctl error: \(error.localizedDescription)")
        }
    }
}
