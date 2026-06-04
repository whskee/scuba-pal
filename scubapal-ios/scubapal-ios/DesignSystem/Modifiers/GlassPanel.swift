import SwiftUI

struct GlassPanel: ViewModifier {
    var radius: CGFloat = 28
    var fill: Color = ScubaTheme.surface.opacity(0.82)
    var border: Color = ScubaTheme.border

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(border, lineWidth: 1)
                    )
            }
            .shadow(color: .black.opacity(0.22), radius: 24, x: 0, y: 16)
    }
}

extension View {
    func glassPanel(
        radius: CGFloat = 28,
        fill: Color = ScubaTheme.surface.opacity(0.82),
        border: Color = ScubaTheme.border
    ) -> some View {
        modifier(GlassPanel(radius: radius, fill: fill, border: border))
    }
}
