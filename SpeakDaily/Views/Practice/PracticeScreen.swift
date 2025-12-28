import SwiftUI

struct PracticeScreen: View {
    @StateObject private var viewModel = PracticeViewModel()
    @State private var showTip: Bool = TipDismissalStore.shouldShowTip()
    @StateObject private var profile = UserProfileStore.shared
    @StateObject private var historyStore = HistoryStore.shared
    @StateObject private var dailyProgress = DailyProgressStore.shared
    @State private var showProgress = false

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

                    if profile.enableCarousel, !historyStore.items.isEmpty {
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVStack(spacing: 16) {
                                    ForEach(historyStore.items) { item in
                                        let isCurrent = item.id == viewModel.currentHistoryID
                                        TranslationCard(
                                            chinese: isCurrent ? viewModel.chineseText : item.cn,
                                            english: isCurrent ? viewModel.englishText : item.en,
                                            alternatives: isCurrent ? viewModel.alternatives : [],
                                            status: isCurrent ? viewModel.status : .ready,
                                            onSelectAlternative: { viewModel.selectAlternative($0) }
                                        )
                                        .id(item.id)
                                        .modifier(CardScrollEffect(enabled: profile.enableCarousel))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .frame(maxHeight: .infinity)
                            .onChange(of: viewModel.currentHistoryID) { _, id in
                                guard let id else { return }
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    proxy.scrollTo(id, anchor: .top)
                                }
                            }
                        }
                    } else {
                        TranslationCard(
                            chinese: viewModel.chineseText,
                            english: viewModel.englishText,
                            alternatives: viewModel.alternatives,
                            status: viewModel.status,
                            onSelectAlternative: { viewModel.selectAlternative($0) }
                        )
                        .frame(maxWidth: .infinity, alignment: .top)
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: 20) {
                        ActionRow(
                            canSpeak: !viewModel.englishText.isEmpty,
                            isFavorite: viewModel.isFavorite,
                            isSpeaking: viewModel.isSpeaking,
                            onSpeak: { viewModel.speakEnglish() },
                            onCopy: { viewModel.copyEnglish() },
                            onSave: { viewModel.toggleFavorite() }
                        )

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
                    }
                    .padding(.bottom, 12)

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
                    Button(action: { showProgress = true }) {
                        Image(systemName: "clock")
                    }
                }
            }
            .sheet(isPresented: $showProgress) {
                VStack(spacing: 16) {
                    Text("今日翻译进度")
                        .font(.headline)
                    ProgressView(value: Double(dailyProgress.count), total: Double(dailyProgress.target))
                        .tint(.blue)
                    Text("\(dailyProgress.count)/\(dailyProgress.target)")
                        .font(.title2.weight(.semibold))
                    Text("达到 12 次即可完成今日目标")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .presentationDetents([.height(220)])
            }
        }
    }
}

private struct CardScrollEffect: ViewModifier {
    let enabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if enabled {
            if #available(iOS 17.0, *) {
                content
                    .scrollTransition(.interactive, axis: .vertical) { view, phase in
                        view
                            .rotation3DEffect(.degrees(phase.value * -12), axis: (x: 1, y: 0, z: 0))
                            .scaleEffect(1 - abs(phase.value) * 0.08)
                            .opacity(1 - abs(phase.value) * 0.2)
                    }
            } else {
                content
            }
        } else {
            content
        }
    }
}
