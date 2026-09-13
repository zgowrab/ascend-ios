import SwiftUI

public struct AscendTheme {
    // Primary Colors
    public static let bgPrimary = Color(red: 10/255, green: 12/255, blue: 16/255)
    public static let bgSecondary = Color(red: 20/255, green: 24/255, blue: 32/255)
    public static let bgCard = Color(red: 28/255, green: 34/255, blue: 46/255).opacity(0.7)
    public static let bgElevated = Color(red: 35/255, green: 42/255, blue: 58/255)
    
    // Accents
    public static let emerald = Color(red: 0/255, green: 240/255, blue: 118/255)
    public static let cyan = Color(red: 0/255, green: 229/255, blue: 255/255)
    public static let amber = Color(red: 255/255, green: 170/255, blue: 0/255)
    public static let flame = Color(red: 255/255, green: 85/255, blue: 51/255)
    public static let purple = Color(red: 168/255, green: 85/255, blue: 247/255)
    
    // Text
    public static let textPrimary = Color.white
    public static let textSecondary = Color(red: 160/255, green: 172/255, blue: 195/255)
    public static let textMuted = Color(red: 100/255, green: 112/255, blue: 130/255)
    
    // Gradients
    public static let primaryGradient = LinearGradient(
        colors: [emerald, cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let flameGradient = LinearGradient(
        colors: [flame, amber],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let cardBorderGradient = LinearGradient(
        colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

public extension View {
    func ascendBackground() -> some View {
        self
            .background(AscendTheme.bgPrimary)
            .preferredColorScheme(.dark)
    }
}
