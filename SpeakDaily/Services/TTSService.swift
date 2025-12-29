import Foundation
import AVFoundation

@MainActor
final class TTSService: NSObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isSpeaking: Bool = false

    private let synthesizer = AVSpeechSynthesizer()
    private let profile = UserProfileStore.shared
    private var onFinished: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speakEnglish(_ text: String, onFinished: (() -> Void)? = nil) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }

        print("🔊 TTS speak:", clean)
        self.onFinished = onFinished
        isSpeaking = true

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("❌ AudioSession playback setup failed:", error)
        }

        let utterance = AVSpeechUtterance(string: clean)
        utterance.voice = resolveVoice()
        let clampedRate = min(max(profile.speechRate, 0.0), 1.0)
        utterance.rate = clampedRate
        let clampedPitch = min(max(profile.speechPitch, 0.5), 2.0)
        utterance.pitchMultiplier = clampedPitch
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        onFinished?()
        onFinished = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        onFinished?()
        onFinished = nil
    }

    private func resolveVoice() -> AVSpeechSynthesisVoice? {
        let preferred = profile.preferredVoiceIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        if !preferred.isEmpty, let voice = AVSpeechSynthesisVoice(identifier: preferred) {
            return voice
        }
        let names = ["Samantha", "Ava", "Allison", "Nicky", "Siri"]
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "en-US" }
        for name in names {
            if let voice = voices.first(where: { $0.name.lowercased().contains(name.lowercased()) }) {
                return voice
            }
        }
        return AVSpeechSynthesisVoice(language: "en-US")
    }
}
