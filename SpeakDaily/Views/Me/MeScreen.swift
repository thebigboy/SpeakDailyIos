import SwiftUI

struct MeScreen: View {
    @State private var saveHistory = true
    @StateObject private var profile = UserProfileStore.shared
    @State private var nameDraft: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Circle().fill(.blue.opacity(0.2))
                            .frame(width: 52, height: 52)
                            .overlay(Text(String(profile.displayName.prefix(1))).font(.title2.bold()).foregroundStyle(.blue))

                        VStack(alignment: .leading) {
                            Text(profile.displayName)
                                .font(.headline)
                            Text("学习天数：3 天")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("设置") {
                    HStack {
                        TextField("首页名称", text: $nameDraft)
                        Button("保存") {
                            profile.updateDisplayName(nameDraft)
                            nameDraft = profile.displayName
                        }
                        .disabled(nameDraft.trimmingCharacters(in: .whitespacesAndNewlines) == profile.displayName)
                    }
                    HStack {
                        Text("语速")
                        Slider(value: $profile.speechRate, in: 0.3...0.7, step: 0.05)
                        Text(String(format: "%.2f", profile.speechRate))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 44, alignment: .trailing)
                    }
                    Toggle("自动朗读英文", isOn: $profile.autoSpeak)
                    Toggle("保存历史记录", isOn: $saveHistory)
                    NavigationLink("翻译偏好") { Text("口语 / 正式 / 简短") }
                    NavigationLink("英语口音") { Text("美式 / 英式") }
                }

                Section("隐私与支持") {
                    NavigationLink("隐私政策") { Text("Privacy Policy") }
                    NavigationLink("意见反馈") { Text("Feedback") }
                    NavigationLink("关于") { Text("SpeakDaily v0.1") }
                }
            }
            .navigationTitle("我的")
            .onAppear {
                if nameDraft.isEmpty {
                    nameDraft = profile.displayName
                }
            }
        }
    }
}
