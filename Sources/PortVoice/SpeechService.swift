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

    /// Most natural installed voice for a localization code (e.g. "en", "id",
    /// "pt-BR", "zh-Hans"), with no configuration and no voice picker.
    ///
    /// 1. The voice macOS itself would use for this language (the user's Spoken
    ///    Content choice) wins when it is already an enhanced or premium voice.
    /// 2. Otherwise the highest-quality installed voice of the same language is
    ///    used, preferring the system choice's region and gender, so the
    ///    character stays familiar but sounds human instead of robotic.
    ///    Novelty voices are never picked: they are all default quality.
    /// 3. Otherwise the system choice is kept, so announcements never break.
    /// Returns nil only when no voice of the language exists; the system default
    /// voice then speaks.
    private static func voice(for localization: String) -> AVSpeechSynthesisVoice? {
        let base = baseLanguage(localization)
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let systemChoice = AVSpeechSynthesisVoice(language: localization)
            ?? voices.first(where: { $0.language == localization })
            ?? voices.first(where: { baseLanguage($0.language) == base })

        if let chosen = systemChoice, chosen.quality != .default {
            return chosen
        }

        func rank(_ v: AVSpeechSynthesisVoice) -> (Int, Int, Int, Int, String) {
            let sameGender = systemChoice.map { $0.gender == v.gender && v.gender != .unspecified } ?? false
            return (v.quality.rawValue,
                    v.language == localization ? 1 : 0,
                    v.language == systemChoice?.language ? 1 : 0,
                    sameGender ? 1 : 0,
                    v.identifier)
        }
        let natural = voices.filter { baseLanguage($0.language) == base && $0.quality != .default }
        return natural.max(by: { rank($0) < rank($1) }) ?? systemChoice
    }

    private static func baseLanguage(_ code: String) -> String {
        code.split(separator: "-").first.map(String.init) ?? code
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
