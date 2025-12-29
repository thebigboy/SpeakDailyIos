import SwiftUI

struct HoldToSpeakButton: View {
    let status: PracticeStatus
    let onStart: () -> Void
    let onEnd: () -> Void

    @State private var pulse = false
    @State private var isPressing = false
    private let coreSize: CGFloat = 92
    private let rippleSize: CGFloat = 150

    var body: some View {
        ZStack {
            // ripple
            Circle()
                .fill((status == .recording ? Color.red : Color.blue).opacity(0.20))
                .frame(width: pulse ? rippleSize : coreSize, height: pulse ? rippleSize : coreSize)
                .opacity(pulse ? 0 : 1)
                .animation(.easeOut(duration: 1.1).repeatForever(autoreverses: false), value: pulse)

            // main
            Circle()
                .fill(status == .recording ? Color.red : Color.blue)
                .frame(width: coreSize, height: coreSize)
                .shadow(radius: 14)

            VStack(spacing: 3) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                Text(status == .recording ? "录音中" : "按住说话")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.95))
            }
        }
        .frame(width: rippleSize, height: rippleSize, alignment: .center)
        .contentShape(Circle())
        .onAppear { pulse = true }
        .onChange(of: status) { _, newStatus in
            print("🎙️ HoldButton status:", String(describing: newStatus))
            if newStatus != .recording {
                isPressing = false
            }
        }
        .highPriorityGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    print("🎙️ HoldButton onChanged, isPressing:", isPressing)
                    guard !isPressing else { return }
                    isPressing = true
                    print("🎙️ HoldButton start recording")
                    onStart()
                }
                .onEnded { _ in
                    print("🎙️ HoldButton onEnded, isPressing:", isPressing)
                    guard isPressing else { return }
                    isPressing = false
                    print("🎙️ HoldButton end recording")
                    onEnd()
                }
        )
        .accessibilityLabel(status == .recording ? "录音中" : "按住说话")
    }
}
