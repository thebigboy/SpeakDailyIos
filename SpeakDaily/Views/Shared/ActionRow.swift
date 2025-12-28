import SwiftUI

struct ActionRow: View {
    let canSpeak: Bool
    let isFavorite: Bool
    let isSpeaking: Bool
    let onSpeak: () -> Void
    let onCopy: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            Button(action: onSpeak) {
                if isSpeaking {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.9)
                        Text("朗读中")
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                } else {
                    Label("朗读", systemImage: "speaker.wave.2.fill")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            //.controlSize(.large)
            .buttonStyle(.borderedProminent)
            .disabled(!canSpeak || isSpeaking)

            Button(action: onCopy) {
                VStack(spacing: 2) {
                    Image(systemName: "doc.on.doc")
                    Text("复制")
                        .font(.caption2)
                }
                .frame(width: 56, height: 44)
            }
            .buttonStyle(.bordered)

            Button(action: onSave) {
                VStack(spacing: 2) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                    Text("收藏")
                        .font(.caption2)
                }
                .frame(width: 56, height: 44)
            }
            .buttonStyle(.bordered)
        }
    }
}
