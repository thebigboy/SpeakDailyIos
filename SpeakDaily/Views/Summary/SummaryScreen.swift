import SwiftUI

struct SummaryScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerCard

                    section(title: "重点词汇") {
                        vocabCard(word: "library", meaning: "图书馆", example: "Let’s go to the library.")
                        vocabCard(word: "study", meaning: "学习", example: "I need to study tonight.")
                    }

                    section(title: "语法点") {
                        grammarCard(title: "want to + 动词", desc: "表示想做某事", example: "I want to go home.")
                    }

                    section(title: "小测验") {
                        quizCard()
                    }
                }
                .padding()
            }
            .navigationTitle("学习总结")
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("本次对话主题：校园生活")
                .font(.headline)

            Text("词汇 8 | 语法 2 | 表达 3")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("重新生成") {}
                .buttonStyle(.borderedProminent)
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

    private func quizCard() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("“我想去图书馆学习” 的英文是：")
                .font(.subheadline)

            ForEach(["I want to go to the library and study.", "I go library study."], id: \ .self) { option in
                Button(option) {}
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
