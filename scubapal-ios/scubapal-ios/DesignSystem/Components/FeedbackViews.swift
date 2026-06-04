import SwiftUI

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImage: String = "sparkles"

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(ScubaTheme.primary)
                .frame(width: 58, height: 58)
                .background(ScubaTheme.surface2.opacity(0.75))
                .clipShape(Circle())
            Text(title)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(ScubaTheme.ink)
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ScubaTheme.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .glassPanel(radius: 26, fill: ScubaTheme.surface.opacity(0.56))
    }
}

struct ToastView: View {
    var toast: ToastState

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.systemImage)
                .foregroundStyle(ScubaTheme.primary)
            Text(toast.message)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ScubaTheme.ink)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(ScubaTheme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
