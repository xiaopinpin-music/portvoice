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

            // Follow the Mac's language automatically (zero configuration), but
            // match the language PortVoice actually displays and speaks in — the
            // app's resolved localization — instead of the raw system list. This
            // keeps the spoken voice and the spoken words in the same language:
            // when a language is translated the voice follows it; when it is not
            // yet translated, both stay in the fallback language rather than
            // mismatching (e.g. an Arabic voice reading English words).
            let appLanguage = Bundle.main.preferredLocalizations.first ?? "en"
            if let voice = SpeechService.voice(for: appLanguage) {
                utterance.voice = voice
            }

            synthesizer.speak(utterance)
        }
    }

    /// Best available speech voice for a localization code (e.g. "id", "pt-BR",
    /// "zh-Hans"). Tries an exact match first, then any installed voice sharing
    /// the same base language (so "zh-Hans" still finds an installed "zh-CN"
    /// voice). Returns nil to let the system default voice handle anything that
    /// cannot be mapped, so announcements never break on any language.
    private static func voice(for localization: String) -> AVSpeechSynthesisVoice? {
        if let exact = AVSpeechSynthesisVoice(language: localization) {
            return exact
        }
        let base = localization.split(separator: "-").first.map(String.init) ?? localization
        let voices = AVSpeechSynthesisVoice.speechVoices()
        if let match = voices.first(where: { $0.language == localization })
            ?? voices.first(where: { $0.language.hasPrefix(base) }) {
            return AVSpeechSynthesisVoice(identifier: match.identifier)
        }
        return nil
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
