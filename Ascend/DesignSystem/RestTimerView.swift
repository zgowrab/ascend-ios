import SwiftUI

public struct RestTimerView: View {
    @Binding var totalSeconds: Int
    @Binding var remainingSeconds: Int
    @Binding var isRunning: Bool
    var onComplete: () -> Void
    var onDismiss: () -> Void
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init(
        totalSeconds: Binding<Int>,
        remainingSeconds: Binding<Int>,
        isRunning: Binding<Bool>,
        onComplete: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self._totalSeconds = totalSeconds
        self._remainingSeconds = remainingSeconds
        self._isRunning = isRunning
        self.onComplete = onComplete
        self.onDismiss = onDismiss
    }
    
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }
    
    private var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    public var body: some View {
        VStack(spacing: 18) {
            HStack {
                Label("Rest & Recovery", systemImage: "timer")
                    .font(.headline)
                    .foregroundStyle(AscendTheme.emerald)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AscendTheme.textMuted)
                }
            }
            
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                // Animated Progress Arc
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        AscendTheme.primaryGradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 150, height: 150)
                    .animation(.snappy(duration: 0.3), value: remainingSeconds)
                
                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AscendTheme.textPrimary)
                    
                    Text(isRunning ? "Breathe Deeply" : "Paused")
                        .font(.caption)
                        .foregroundStyle(AscendTheme.textSecondary)
                }
            }
            .padding(.vertical, 8)
            
            // Quick Controls
            HStack(spacing: 16) {
                Button {
                    remainingSeconds = max(5, remainingSeconds - 15)
                } label: {
                    Text("-15s")
                        .font(.subheadline.bold())
                        .foregroundStyle(AscendTheme.textSecondary)
                        .frame(width: 60, height: 40)
                        .background(AscendTheme.bgElevated)
                        .clipShape(Capsule())
                }
                
                Button {
                    isRunning.toggle()
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title3.bold())
                        .foregroundStyle(AscendTheme.bgPrimary)
                        .frame(width: 60, height: 40)
                        .background(AscendTheme.emerald)
                        .clipShape(Capsule())
                }
                
                Button {
                    remainingSeconds += 30
                    totalSeconds += 30
                } label: {
                    Text("+30s")
                        .font(.subheadline.bold())
                        .foregroundStyle(AscendTheme.textSecondary)
                        .frame(width: 60, height: 40)
                        .background(AscendTheme.bgElevated)
                        .clipShape(Capsule())
                }
                
                Button {
                    onComplete()
                } label: {
                    Text("Skip")
                        .font(.subheadline.bold())
                        .foregroundStyle(AscendTheme.amber)
                        .frame(width: 60, height: 40)
                        .background(AscendTheme.bgElevated)
                        .clipShape(Capsule())
                }
            }
        }
        .glassCardStyle(cornerRadius: 24, padding: 20)
        .onReceive(timer) { _ in
            guard isRunning else { return }
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                isRunning = false
                onComplete()
            }
        }
    }
}
