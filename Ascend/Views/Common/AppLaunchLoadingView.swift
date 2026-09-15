import SwiftUI

public struct AppLaunchLoadingView: View {
    @State private var isAnimating: Bool = false
    @State private var progress: CGFloat = 0.0
    @State private var statusIndex: Int = 0
    
    private let statusMessages = [
        "Initializing Engine...",
        "Syncing Athlete Profile...",
        "Loading Movement Catalog...",
        "Priming Nutrition Vault...",
        "Ready."
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // High-Performance Deep Charcoal Stage
            AscendTheme.bgPrimary
                .ignoresSafeArea()
            
            // Atmospheric Ambient Neon Glows
            ZStack {
                Circle()
                    .fill(AscendTheme.emerald.opacity(isAnimating ? 0.22 : 0.08))
                    .frame(width: 280, height: 280)
                    .blur(radius: 65)
                    .offset(x: -40, y: -60)
                
                Circle()
                    .fill(AscendTheme.cyan.opacity(isAnimating ? 0.18 : 0.06))
                    .frame(width: 240, height: 240)
                    .blur(radius: 55)
                    .offset(x: 40, y: 50)
            }
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Main Branding Crest & Status
            VStack(spacing: 28) {
                Spacer()
                
                // Animated Geometric Ascend Emblem
                ZStack {
                    // Outer Hexagonal / Rounded Card Ring
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(AscendTheme.bgElevated.opacity(0.85))
                        .frame(width: 104, height: 104)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [AscendTheme.emerald, AscendTheme.cyan.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: AscendTheme.emerald.opacity(0.35), radius: 24, x: 0, y: 8)
                    
                    // Upward Chevrons / Arrow Emblem
                    VStack(spacing: -8) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 26, weight: .black))
                            .foregroundStyle(AscendTheme.emerald)
                        
                        Image(systemName: "chevron.up")
                            .font(.system(size: 34, weight: .black))
                            .foregroundStyle(AscendTheme.cyan)
                    }
                    .scaleEffect(isAnimating ? 1.04 : 0.96)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                // Brand Typography
                VStack(spacing: 8) {
                    Text("ASCEND")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .tracking(8)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(white: 0.88)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("HIGH-PERFORMANCE PHYSIQUE ENGINE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(2.5)
                        .foregroundStyle(AscendTheme.emerald)
                }
                
                Spacer()
                
                // Futuristic Laser Loading Bar & Status
                VStack(spacing: 12) {
                    // Progress Track
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AscendTheme.bgElevated)
                            .frame(width: 200, height: 4)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AscendTheme.cyan, AscendTheme.emerald],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, 200 * progress), height: 4)
                            .shadow(color: AscendTheme.emerald.opacity(0.8), radius: 6, x: 0, y: 0)
                    }
                    
                    // Rotating Status Label
                    Text(statusMessages[min(statusIndex, statusMessages.count - 1)])
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(AscendTheme.textSecondary)
                        .transition(.opacity)
                        .id(statusIndex)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            isAnimating = true
            
            // Smooth progress animation from 0.0 to 1.0
            withAnimation(.easeInOut(duration: 1.1)) {
                progress = 1.0
            }
            
            // Cycle through status messages
            Timer.scheduledTimer(withTimeInterval: 0.28, repeats: true) { timer in
                Task { @MainActor in
                    if statusIndex < statusMessages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            statusIndex += 1
                        }
                    } else {
                        timer.invalidate()
                    }
                }
            }
        }
    }
}
