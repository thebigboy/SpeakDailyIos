import Foundation

@MainActor
final class UserProfileStore: ObservableObject {
    static let shared = UserProfileStore()

    @Published var displayName: String {
        didSet { UserDefaults.standard.set(displayName, forKey: nameKey) }
    }
    @Published var speechRate: Float {
        didSet { UserDefaults.standard.set(speechRate, forKey: rateKey) }
    }
    @Published var speechPitch: Float {
        didSet { UserDefaults.standard.set(speechPitch, forKey: pitchKey) }
    }
    @Published var autoSpeak: Bool {
        didSet { UserDefaults.standard.set(autoSpeak, forKey: autoSpeakKey) }
    }
    @Published var enableCarousel: Bool {
        didSet { UserDefaults.standard.set(enableCarousel, forKey: carouselKey) }
    }
    @Published var preferredVoiceIdentifier: String {
        didSet { UserDefaults.standard.set(preferredVoiceIdentifier, forKey: voiceKey) }
    }

    private let nameKey = "user.displayName"
    private let rateKey = "tts.speechRate"
    private let pitchKey = "tts.speechPitch"
    private let autoSpeakKey = "tts.autoSpeak"
    private let carouselKey = "ui.carouselEnabled"
    private let voiceKey = "tts.voiceIdentifier"

    private init() {
        let saved = UserDefaults.standard.string(forKey: nameKey)
        displayName = saved?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? saved!.trimmingCharacters(in: .whitespacesAndNewlines)
            : "Kerwin"
        let storedRate = UserDefaults.standard.object(forKey: rateKey) as? Float
        speechRate = storedRate ?? 0.5
        let storedPitch = UserDefaults.standard.object(forKey: pitchKey) as? Float
        speechPitch = storedPitch ?? 1.05
        let storedAutoSpeak = UserDefaults.standard.object(forKey: autoSpeakKey) as? Bool
        autoSpeak = storedAutoSpeak ?? true
        let storedCarousel = UserDefaults.standard.object(forKey: carouselKey) as? Bool
        enableCarousel = storedCarousel ?? false
        let storedVoice = UserDefaults.standard.string(forKey: voiceKey)
        preferredVoiceIdentifier = storedVoice ?? ""
    }

    func updateDisplayName(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        displayName = trimmed.isEmpty ? "Kerwin" : trimmed
    }

    func updatePreferredVoiceIdentifier(_ identifier: String) {
        preferredVoiceIdentifier = identifier
    }
}
