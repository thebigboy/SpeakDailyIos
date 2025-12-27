# SpeakDaily (iOS)

一个面向学生的日常英语口语学习 App：  
**按住录音说中文 → 自动识别 → 调用 DeepSeek 翻译成地道英文 → 一键朗读 → 生成学习总结（词汇 / 语法 / 小测验）**

> 技术栈：SwiftUI + AVAudioRecorder + Apple Speech + DeepSeek API + AVSpeechSynthesizer  
> 当前版本：MVP 已完成核心闭环（录音 → 识别 → 翻译 → 朗读）

---

## ✨ 核心功能

### ✅ 已实现（MVP 可用）
- ✅ SwiftUI 原生 iOS App
- ✅ 底部 TabBar：**练习 / 历史 / 总结 / 我的**
- ✅ **按住录音**（AVAudioRecorder）
- ✅ **中文语音识别**（SFSpeechRecognizer，zh-CN）
- ✅ **DeepSeek 翻译口语英文**（严格 JSON 输出 + 解析）
- ✅ **展示英文结果 + alternatives**
- ✅ **TTS 英文朗读**（AVSpeechSynthesizer，en-US）
- ✅ 复制英文到剪贴板
- ✅ 错误提示 Alert / 权限异常状态提示

### 🟡 部分完成
- 🟡 总结页支持调用 DeepSeek 生成总结，但当前对话源为 hardcoded（后续会连接练习页真实对话）

### ❌ 待实现（下一阶段）
- ❌ 历史记录持久化（保存练习记录）
- ❌ 收藏功能持久化
- ❌ 总结页与真实练习记录联动
- ❌ 翻译结果展示 keywords / grammar（目前仅解析未展示）
- ❌ 登录 / 用户体系（可选）

---

## 📱 运行环境
- iOS 16+（建议）
- Xcode 15+
- Swift 5.9+

> 注意：Apple Speech 在模拟器上可能不稳定，建议第一次测试使用真机。

---

## 🚀 快速开始

### 1）克隆代码并打开工程
```bash
git clone https://github.com/thebigboy/SpeakDaily.git
cd SpeakDaily
open SpeakDaily.xcodeproj
```

### 2）配置 Info.plist（必需）
在 Xcode -> `Info.plist` 添加以下 Key（如果已配置可跳过）：

#### ✅ 权限配置（必须）
- `Privacy - Microphone Usage Description`  
  示例：`用于录音并识别你的中文，生成英文表达`
- `Privacy - Speech Recognition Usage Description`  
  示例：`用于把你的语音转换成文字，帮助你学习英语`

#### ✅ DeepSeek API Key（必须）
- `DEEPSEEK_API_KEY`  
  值为你的 DeepSeek Key，例如：`sk-xxxx`

### 3）运行
选择真机（推荐）或模拟器后：
- `⌘R` 运行 App

---

## 🧩 使用方式（MVP）

### ✅ 练习页
1. **按住录音按钮**开始说中文
2. 松开后自动：
   - 识别语音为中文文本
   - 调用 DeepSeek 翻译为英文
3. 结果显示：
   - 中文原句
   - 英文翻译
   - 2-3 个替代表达
4. 点击：
   - **朗读**：播放英文 TTS
   - **复制**：复制英文到剪贴板
   - **收藏**：切换收藏状态（暂未持久化）

### ✅ 总结页
点击 “生成总结”：
- DeepSeek 输出学习总结结构（JSON）
- App 渲染：
  - 重点词汇（word/meaning/example）
  - 语法点（title/explanation/example）
  - 小测验（question/options）

---

## 📁 项目结构

```
SpeakDaily/
  Models/
    ConversationMessage.swift
    SummaryModels.swift

  Services/
    AudioRecorderService.swift    # 录音
    SpeechService.swift           # 中文识别
    DeepSeekService.swift         # DeepSeek 翻译与总结
    TTSService.swift              # 朗读英文
    PromptTemplates.swift         # Prompt 模板（强制 JSON）

  ViewModels/
    PracticeViewModel.swift       # 串联 录音→识别→翻译→朗读

  Views/
    Practice/PracticeScreen.swift
    History/HistoryScreen.swift
    Summary/SummaryScreen.swift
    Me/MeScreen.swift
    Shared/
      HoldToSpeakButton.swift
      TipCard.swift
      TranslationCard.swift
      ActionRow.swift
      PracticeStatus.swift
```

---

## 🧠 DeepSeek API 输出格式（Translation）

### 翻译接口严格输出 JSON（示例）
```json
{
  "english": "Good morning, how are you?",
  "alternatives": [
    "Morning! How are you doing?",
    "Hi! How’s it going?"
  ],
  "keywords": ["morning", "how are you", "doing"],
  "grammar": ["问候语 + 问近况表达"]
}
```

---

## ⚠️ 常见问题（FAQ）

### Q1：Speech 识别为空/失败？
- 确认 `Speech Recognition` 权限已允许
- 模拟器上不稳定，建议用真机测试

### Q2：DeepSeek 返回解析失败？
- 确认 `DEEPSEEK_API_KEY` 已配置正确
- 可能返回内容不是纯 JSON，可检查 DeepSeekService 的 JSON 提取函数

### Q3：日志提示 Gesture gate timed out？
- 这是 iOS 对手势调度的警告（warning）
- 一般不影响功能
- 后续可把 `DragGesture` 换成 `onLongPressGesture` 以提升稳定性

---

## 🛣 Roadmap（下一步计划）

- [ ] 将练习结果保存到本地（SwiftData / CoreData）
- [ ] 历史页显示真实记录 + 搜索
- [ ] 收藏功能持久化
- [ ] 总结页连接真实对话内容（lastConversation / history item）
- [ ] 展示 keywords / grammar 学习点
- [ ] iCloud 同步（可选）
- [ ] 上架 App Store

---

## 📄 License
MIT

---

## 🙌 Credits
- DeepSeek API
- Apple Speech Framework
- SwiftUI & AVFoundation
