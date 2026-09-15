import SwiftUI

public struct ExerciseDemonstrationView: View {
    let exerciseName: String
    let muscleGroup: MuscleGroup
    var height: CGFloat = 280
    
    @State private var activePhaseIndex: Int = 0 // 0 = Setup/Start, 1 = Peak Contraction
    @State private var isAutoLooping: Bool = true
    @State private var timer: Timer? = nil
    
    private var demonstration: ExerciseDemonstration {
        ExerciseDemonstrationProvider.resolve(for: exerciseName, muscleGroup: muscleGroup)
    }
    
    public init(exerciseName: String, muscleGroup: MuscleGroup, height: CGFloat = 280) {
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.height = height
    }
    
    public var body: some View {
        ZStack {
            // Stage Background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AscendTheme.bgSecondary, AscendTheme.bgPrimary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AscendTheme.cardBorder, lineWidth: 1)
                )
            
            // Image Display Area with Cross-Fade
            GeometryReader { geo in
                ZStack {
                    if activePhaseIndex == 0 {
                        demonstrationImage(url: demonstration.setupImageURL, label: "Setup & Start")
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    } else {
                        demonstrationImage(url: demonstration.contractionImageURL, label: "Peak Contraction")
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(.easeInOut(duration: 0.35), value: activePhaseIndex)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Bottom Subtle Gradient Vignette to enhance readability of controls
            VStack {
                Spacer()
                LinearGradient(
                    colors: [Color.clear, AscendTheme.bgPrimary.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 70)
                .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // UI Overlay Controls
            VStack {
                // Top Header Controls
                HStack {
                    // Current Phase Indicator Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(activePhaseIndex == 0 ? AscendTheme.cyan : AscendTheme.emerald)
                            .frame(width: 7, height: 7)
                        
                        Text(activePhaseIndex == 0 ? "PHASE 1 • START & SETUP" : "PHASE 2 • PEAK CONTRACTION")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(AscendTheme.textPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(activePhaseIndex == 0 ? AscendTheme.cyan.opacity(0.4) : AscendTheme.emerald.opacity(0.4), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    // Auto-Play / Pause Button
                    Button {
                        isAutoLooping.toggle()
                        if isAutoLooping {
                            startLoopTimer()
                        } else {
                            stopLoopTimer()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isAutoLooping ? "pause.fill" : "play.fill")
                                .font(.caption2.bold())
                            Text(isAutoLooping ? "Looping" : "Paused")
                                .font(.caption2.bold())
                        }
                        .foregroundStyle(isAutoLooping ? AscendTheme.emerald : AscendTheme.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                
                Spacer()
                
                // Bottom Interactive Phase Selector Tabs
                HStack(spacing: 8) {
                    phaseTabButton(title: "1. Start Setup", index: 0)
                    phaseTabButton(title: "2. Peak Contraction", index: 1)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
        }
        .frame(height: height)
        .onAppear {
            if isAutoLooping {
                startLoopTimer()
            }
        }
        .onDisappear {
            stopLoopTimer()
        }
    }
    
    // MARK: - Photo Renderer with AsyncImage
    private func demonstrationImage(url: URL?, label: String) -> some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            AscendTheme.bgSecondary
                            VStack(spacing: 10) {
                                ProgressView()
                                    .tint(AscendTheme.emerald)
                                Text("Loading form demonstration...")
                                    .font(.caption2)
                                    .foregroundStyle(AscendTheme.textSecondary)
                            }
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .failure:
                        fallbackCard(errorText: "Demonstration image unavailable")
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                fallbackCard(errorText: "Demonstration not available")
            }
        }
    }
    
    // MARK: - Phase Tab Button
    private func phaseTabButton(title: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                activePhaseIndex = index
            }
            // Temporarily pause auto loop on manual tap for closer inspection
            isAutoLooping = false
            stopLoopTimer()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: index == 0 ? "figure.stand" : "figure.strengthtraining.traditional")
                    .font(.caption2)
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(activePhaseIndex == index ? AscendTheme.emerald : Color.black.opacity(0.45))
            .foregroundStyle(activePhaseIndex == index ? AscendTheme.bgPrimary : AscendTheme.textSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(activePhaseIndex == index ? AscendTheme.emerald : AscendTheme.cardBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Fallback Card
    private func fallbackCard(errorText: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 40))
                .foregroundStyle(AscendTheme.emerald)
            
            Text(exerciseName)
                .font(.headline.bold())
                .foregroundStyle(AscendTheme.textPrimary)
            
            Text(muscleGroup.rawValue.uppercased())
                .font(.caption2.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AscendTheme.cyan.opacity(0.18))
                .foregroundStyle(AscendTheme.cyan)
                .clipShape(Capsule())
            
            Text(errorText)
                .font(.caption2)
                .foregroundStyle(AscendTheme.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
    
    // MARK: - Cadence Loop Timer
    private func startLoopTimer() {
        stopLoopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.35)) {
                    activePhaseIndex = (activePhaseIndex == 0 ? 1 : 0)
                }
            }
        }
    }
    
    private func stopLoopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
