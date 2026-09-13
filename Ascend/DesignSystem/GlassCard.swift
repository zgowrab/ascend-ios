import SwiftUI

public struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let padding: CGFloat
    @ViewBuilder let content: () -> Content
    
    public init(
        cornerRadius: CGFloat = 18,
        padding: CGFloat = 16,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(AscendTheme.bgCard)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(AscendTheme.cardBorderGradient, lineWidth: 1)
                    )
            }
    }
}

public extension View {
    func glassCardStyle(cornerRadius: CGFloat = 18, padding: CGFloat = 16) -> some View {
        self.padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(AscendTheme.bgCard)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(AscendTheme.cardBorderGradient, lineWidth: 1)
                    )
            }
    }
}
