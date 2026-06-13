import Foundation
import AVFoundation

@MainActor
final class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    private var pendingTask: Task<Void, Never>?

    /// When true, announcements stay silent while the Mac is in Do Not Disturb
    /// or a Focus — the Apple-like, well-behaved default. Driven by the user's
    /// "Respect Do Not Disturb" setting.
    var respectsDoNotDisturb = true

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        // Respect the user's notification context: stay quiet during Do Not
        // Disturb / Focus when asked to.
        if respectsDoNotDisturb && DoNotDisturbStatus.isActive {
            return
        }

        pendingTask?.cancel()

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        pendingTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }

            let utterance = AVSpeechUtterance(string: cleanText)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate

            // Follow the Mac's language automatically (zero configuration): use a
            // voice for the user's preferred language so announcements sound
            // native. Falls back to the system default voice when one is not
            // available, so it never breaks on any language.
            if let language = Locale.preferredLanguages.first,
               let voice = AVSpeechSynthesisVoice(language: language) {
                utterance.voice = voice
            }

            synthesizer.speak(utterance)
        }
    }

    func stop() {
        pendingTask?.cancel()
        pendingTask = nil

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

/// Best-effort Do Not Disturb / Focus detection. macOS offers no stable public
/// API across all versions, so this errs on the side of speaking (returns
/// `false`) whenever it cannot be certain — better to announce than to wrongly
/// stay silent.
enum DoNotDisturbStatus {
    static var isActive: Bool {
        // Big Sur / Monterey expose a simple per-host Do Not Disturb flag.
        if let value = CFPreferencesCopyValue(
            "doNotDisturb" as CFString,
            "com.apple.notificationcenterui" as CFString,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        ) as? NSNumber {
            return value.boolValue
        }
        // Newer Focus state has no stable public signal — default to speaking.
        return false
    }
}
