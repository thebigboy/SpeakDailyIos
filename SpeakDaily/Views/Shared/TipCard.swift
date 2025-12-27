import SwiftUI

struct TipCard: View {
    let status: PracticeStatus
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 6) {
                Text("按住按钮说中文\n我帮你翻译成地道英语")
                    .font(.body.weight(.semibold))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Text(status.statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

//            ZStack {
//                Circle().fill(.blue.opacity(0.15))
//                Image(systemName: "mic.fill")
//                    .foregroundStyle(.blue)
//            }
//            .frame(width: 44, height: 44)
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
