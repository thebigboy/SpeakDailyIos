import SwiftUI

struct TranslationCard: View {
    let chinese: String
    let english: String
    let alternatives: [String]
    let status: PracticeStatus
    let onSelectAlternative: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("你的中文")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(chinese.isEmpty ? "等待输入..." : chinese)
                .font(.body)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("翻译英文")
                .font(.caption)
                .foregroundStyle(.secondary)

            if status == .processing || status == .translating {
                ProgressView("生成中…")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                Text(english.isEmpty ? "翻译结果会显示在这里" : english)
                    .font(.title3.weight(.semibold))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }

            if !alternatives.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(alternatives, id: \ .self) { alt in
                        Button(action: { onSelectAlternative(alt) }) {
                            Text(alt)
                                .font(.footnote)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.blue.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
    }
}
