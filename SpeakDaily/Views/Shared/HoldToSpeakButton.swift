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

            VStack(spacing: 6) {
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
        .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 24, pressing: { pressing in
            if pressing {
                guard !isPressing else { return }
                isPressing = true
                onStart()
            } else {
                guard isPressing else { return }
                isPressing = false
                onEnd()
            }
        }, perform: {})
        .accessibilityLabel(status == .recording ? "录音中" : "按住说话")
    }
}
