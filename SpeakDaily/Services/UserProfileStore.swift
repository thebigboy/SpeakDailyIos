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
    @Published var autoSpeak: Bool {
        didSet { UserDefaults.standard.set(autoSpeak, forKey: autoSpeakKey) }
    }
    @Published var enableCarousel: Bool {
        didSet { UserDefaults.standard.set(enableCarousel, forKey: carouselKey) }
    }

    private let nameKey = "user.displayName"
    private let rateKey = "tts.speechRate"
    private let autoSpeakKey = "tts.autoSpeak"
    private let carouselKey = "ui.carouselEnabled"

    private init() {
        let saved = UserDefaults.standard.string(forKey: nameKey)
        displayName = saved?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? saved!.trimmingCharacters(in: .whitespacesAndNewlines)
            : "Kerwin"
        let storedRate = UserDefaults.standard.object(forKey: rateKey) as? Float
        speechRate = storedRate ?? 0.5
        let storedAutoSpeak = UserDefaults.standard.object(forKey: autoSpeakKey) as? Bool
        autoSpeak = storedAutoSpeak ?? true
        let storedCarousel = UserDefaults.standard.object(forKey: carouselKey) as? Bool
        enableCarousel = storedCarousel ?? false
    }

    func updateDisplayName(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        displayName = trimmed.isEmpty ? "Kerwin" : trimmed
    }
}
