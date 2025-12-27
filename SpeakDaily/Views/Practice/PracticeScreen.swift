import SwiftUI

struct PracticeScreen: View {
    @StateObject private var viewModel = PracticeViewModel()
    @State private var showTip: Bool = TipDismissalStore.shouldShowTip()
    @StateObject private var profile = UserProfileStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 16) {
                    if showTip {
                        TipCard(status: viewModel.status) {
                            TipDismissalStore.dismissForOneMonth()
                            showTip = false
                        }
                    }

                    TranslationCard(
                        chinese: viewModel.chineseText,
                        english: viewModel.englishText,
                        alternatives: viewModel.alternatives,
                        status: viewModel.status,
                        onSelectAlternative: { viewModel.selectAlternative($0) }
                    )

                    ActionRow(
                        canSpeak: !viewModel.englishText.isEmpty,
                        isFavorite: viewModel.isFavorite,
                        isSpeaking: viewModel.isSpeaking,
                        onSpeak: { viewModel.speakEnglish() },
                        onCopy: { viewModel.copyEnglish() },
                        onSave: { viewModel.toggleFavorite() }
                    )

                    Spacer()

                    HoldToSpeakButton(
                        status: viewModel.status,
                        onStart: {
                            if viewModel.status == .idle || viewModel.status == .ready {
                                viewModel.startRecording()
                            }
                        },
                        onEnd: {
                            if viewModel.status == .recording {
                                viewModel.stopRecordingAndProcess()
                            }
                        }
                    )

                    Text("按住录音 · 松开结束 · 自动翻译成口语英语")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }
                .padding()
            }
            .navigationTitle("英语练习")
            .onAppear {
                showTip = TipDismissalStore.shouldShowTip()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(profile.displayName)
                            .font(.headline)
                        Text("英语练习")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "clock")
                    }
                }
            }
        }
    }
}
