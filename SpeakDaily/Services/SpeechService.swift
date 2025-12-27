import Foundation
import Speech
import AVFoundation

enum SpeechServiceError: Error {
    case notAuthorized
    case recognizerUnavailable
    case emptyResult
}

final class SpeechService {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))

    func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }
    }

    func transcribe(audioURL: URL) async throws -> String {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            throw SpeechServiceError.notAuthorized
        }
        guard let recognizer, recognizer.isAvailable else {
            throw SpeechServiceError.recognizerUnavailable
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false

        return try await withCheckedThrowingContinuation { cont in
            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                guard let result, result.isFinal else { return }
                let text = result.bestTranscription.formattedString
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    cont.resume(throwing: SpeechServiceError.emptyResult)
                } else {
                    cont.resume(returning: text)
                }
            }
        }
    }
}

