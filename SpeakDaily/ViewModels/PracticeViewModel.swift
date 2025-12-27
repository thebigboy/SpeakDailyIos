import Foundation
import SwiftUI

@MainActor
final class PracticeViewModel: ObservableObject {
    @Published var status: PracticeStatus = .idle
    @Published var chineseText: String = ""
    @Published var englishText: String = ""
    @Published var alternatives: [String] = []
    @Published var errorMessage: String? = nil
    @Published var isFavorite: Bool = false
    @Published var isSpeaking: Bool = false
    @Published var currentHistoryID: UUID? = nil

    @Published var lastConversation: [ConversationMessage] = []

    private let recorder = AudioRecorderService()
    private let speech = SpeechService()
    private let deepseek = DeepSeekService()
    private let tts = TTSService()
    private let historyStore = HistoryStore.shared
    private let profile = UserProfileStore.shared

    init() {
        Task { await requestPermissionsIfNeeded() }
    }

    func requestPermissionsIfNeeded() async {
        let mic = await recorder.requestPermission()
        let speechStatus = await speech.requestAuthorization()

        if !mic || speechStatus != .authorized {
            status = .permissionDenied
            errorMessage = "请在系统设置中开启麦克风与语音识别权限"
        }
    }

    func startRecording() {
        guard status != .permissionDenied else { return }
        do {
            status = .recording
            try recorder.start()
        } catch {
            status = .error
            errorMessage = "录音启动失败：\(error.localizedDescription)"
        }
    }

    func stopRecordingAndProcess() {
        guard status == .recording else { return }
        guard let url = recorder.stop() else {
            status = .error
            errorMessage = "未获取到录音文件"
            return
        }
        Task {
            await processAudio(url: url)
        }
    }

    private func processAudio(url: URL) async {
        do {
            status = .processing
            let cn = try await speech.transcribe(audioURL: url)
            chineseText = cn

            status = .translating
            let res = try await deepseek.translateToEnglish(chinese: cn)
            englishText = res.english
            alternatives = res.alternatives

            lastConversation = [
                ConversationMessage(role: .user, content: cn),
                ConversationMessage(role: .assistant, content: res.english)
            ]

            let entry = historyStore.addEntry(cn: cn, en: res.english)
            currentHistoryID = entry.id
            isFavorite = entry.isFavorite

            status = .ready
            if profile.autoSpeak {
                speakEnglish()
            }
        } catch {
            status = .error
            errorMessage = error.localizedDescription
        }
    }

    func speakEnglish() {
        guard !englishText.isEmpty else { return }
        status = .speaking
        isSpeaking = true
        tts.speakEnglish(englishText) { [weak self] in
            guard let self else { return }
            self.isSpeaking = false
            if self.status == .speaking {
                self.status = .ready
            }
        }
    }

    func copyEnglish() {
        UIPasteboard.general.string = englishText
    }

    func toggleFavorite() {
        guard let id = currentHistoryID else { return }
        isFavorite = historyStore.toggleFavorite(id: id)
    }

    func selectAlternative(_ text: String) {
        englishText = text
        if let id = currentHistoryID {
            historyStore.updateEnglish(id: id, en: text)
        }
    }
}
