import SwiftUI

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    ScubaTheme.backgroundGradient.ignoresSafeArea()
                    LinearGradient(
                        colors: [
                            ScubaTheme.primary.opacity(0.14),
                            Color.clear,
                            ScubaTheme.secondary.opacity(0.08),
                            ScubaTheme.accent.opacity(0.06)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                    .ignoresSafeArea()
                }
            }
            .preferredColorScheme(.dark)
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackground())
    }

    func pressScale(_ pressed: Bool) -> some View {
        scaleEffect(pressed ? 0.975 : 1)
            .animation(.snappy(duration: 0.18), value: pressed)
    }
}
