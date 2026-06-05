import Foundation
import AVFoundation

@MainActor
final class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    private var pendingTask: Task<Void, Never>?

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanText.isEmpty else { return }

        pendingTask?.cancel()

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        pendingTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }

            let utterance = AVSpeechUtterance(string: cleanText)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.volume = 1.0

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
