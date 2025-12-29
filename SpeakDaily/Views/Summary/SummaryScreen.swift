import SwiftUI

struct SummaryScreen: View {
    @StateObject private var viewModel = SummaryViewModel()
    @StateObject private var summaryStore = SummaryStore.shared
    @State private var collapsedSections: Set<String> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.sections.isEmpty {
                    VStack(spacing: 12) {
                        Text("暂无会话记录")
                            .font(.headline)
                        Text("先去练习页面完成几次翻译吧")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)
                } else {
                    LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                        ForEach(viewModel.sections) { sectionData in
                            Section {
                                VStack(alignment: .leading, spacing: 16) {
                                    if !collapsedSections.contains(sectionData.id) {
                                        HStack {
                                            Button(sectionData.summary == nil ? "生成总结" : "重新生成") {
                                                Task { await viewModel.generateSummary(for: sectionData.id) }
                                            }
                                            .buttonStyle(.bordered)
                                            .disabled(sectionData.isLoading || sectionData.entries.isEmpty)
                                            Spacer()
                                        }
                                    }

                                    if collapsedSections.contains(sectionData.id) {
                                        EmptyView()
                                    } else if sectionData.isLoading {
                                        ProgressView("正在生成总结…")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else if let error = sectionData.errorMessage {
                                        Text("生成失败：\(error)")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    } else if let summary = sectionData.summary {
                                        headerCard(summary: summary)

                                        section(title: "重点词汇") {
                                            ForEach(Array(summary.vocab.prefix(10))) { item in
                                                vocabCard(word: item.word, meaning: item.meaning, example: item.example)
                                            }
                                        }

                                        section(title: "语法点") {
                                            ForEach(Array(summary.grammar.prefix(10))) { item in
                                                grammarCard(title: item.title, desc: item.explanation, example: item.example)
                                            }
                                        }

                                        section(title: "小测验") {
                                            let score = quizScore(summary: summary, dayKey: sectionData.id)
                                            if let score {
                                                Text("得分：\(score.correct)/\(score.total)")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            ForEach(Array(summary.quiz.prefix(10))) { item in
                                                quizCard(item: item, dayKey: sectionData.id)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            } header: {
                                summaryHeader(for: sectionData)
                                    .background(Color(.systemBackground).opacity(0.96))
                                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("学习总结")
            .task {
                viewModel.load()
            }
        }
    }

    private func summaryHeader(for sectionData: SummarySection) -> some View {
        let canCollapse = sectionData.summary != nil
        let isCollapsed = collapsedSections.contains(sectionData.id)
        return Button(action: {
            guard canCollapse else { return }
            if isCollapsed {
                collapsedSections.remove(sectionData.id)
            } else {
                collapsedSections.insert(sectionData.id)
            }
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(viewModel.displayDate(sectionData.date))
                        .font(.headline)
                    Spacer()
                    if canCollapse {
                        Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                            .foregroundStyle(.secondary)
                    }
                }
                Text("\(sectionData.entries.count)次对话")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }

    private func headerCard(summary: SummaryResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("本次对话主题：\(summary.topic)")
                .font(.headline)

            Text("词汇 \(summary.vocab.count) | 语法 \(summary.grammar.count) | 小测 \(summary.quiz.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
            content()
        }
    }

    private func vocabCard(word: String, meaning: String, example: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(word).font(.headline)
            Text(meaning).font(.subheadline).foregroundStyle(.secondary)
            Text(example).font(.footnote)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func grammarCard(title: String, desc: String, example: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(desc).font(.subheadline).foregroundStyle(.secondary)
            Text("例句：\(example)").font(.footnote)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func quizCard(item: QuizItem, dayKey: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.question)
                .font(.subheadline)

            ForEach(Array(item.options.enumerated()), id: \.offset) { index, option in
                let selected = summaryStore.answers(for: dayKey)[item.question] == index
                Button(option) {
                    summaryStore.updateAnswer(dayKey: dayKey, question: item.question, selectedIndex: index)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selected ? Color.blue : Color.clear, lineWidth: 1.5)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func quizScore(summary: SummaryResult, dayKey: String) -> (correct: Int, total: Int)? {
        let answers = summaryStore.answers(for: dayKey)
        guard !answers.isEmpty else { return nil }
        let total = summary.quiz.count
        let correct = summary.quiz.filter { answers[$0.question] == $0.answerIndex }.count
        return (correct, total)
    }
}
