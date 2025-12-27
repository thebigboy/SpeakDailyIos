import Foundation

enum PracticeStatus {
    case idle, recording, processing, translating, ready, speaking, permissionDenied, error

    var statusText: String {
        switch self {
        case .idle: return "● 待机中"
        case .recording: return "● 录音中..."
        case .processing: return "● 正在识别中文..."
        case .translating: return "● 正在翻译..."
        case .ready: return "● 已完成"
        case .speaking: return "● 正在朗读..."
        case .permissionDenied: return "● 权限未开启"
        case .error: return "● 出错了，请重试"
        }
    }
}
