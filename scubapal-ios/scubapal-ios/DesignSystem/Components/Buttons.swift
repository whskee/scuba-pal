import SwiftUI

struct ScubaButton: View {
    enum Style {
        case primary
        case quiet
        case danger
    }

    var title: String
    var systemImage: String?
    var style: Style = .primary
    var isLoading = false
    var isDisabled = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                if isLoading {
                    ProgressView()
                        .tint(foreground)
                        .controlSize(.small)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 15, weight: .heavy))
                    .lineLimit(1)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.48 : 1)
    }

    private var background: Color {
        switch style {
        case .primary: ScubaTheme.primary
        case .quiet: ScubaTheme.surface2.opacity(0.75)
        case .danger: ScubaTheme.danger.opacity(0.18)
        }
    }

    private var foreground: Color {
        switch style {
        case .primary: ScubaTheme.darkText
        case .quiet: ScubaTheme.ink
        case .danger: ScubaTheme.danger
        }
    }

    private var border: Color {
        switch style {
        case .primary: ScubaTheme.primary.opacity(0.6)
        case .quiet: ScubaTheme.border
        case .danger: ScubaTheme.danger.opacity(0.35)
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.84 : 1)
            .pressScale(configuration.isPressed)
    }
}

struct IconCircleButton: View {
    var systemImage: String
    var badge: Int = 0
    var size: CGFloat = 44
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: systemImage)
                    .font(.system(size: size * 0.43, weight: .bold))
                    .foregroundStyle(ScubaTheme.ink)
                    .frame(width: size, height: size)
                    .background(ScubaTheme.surface.opacity(0.86))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(ScubaTheme.border, lineWidth: 1))

                if badge > 0 {
                    Text(badge > 99 ? "99+" : "\(badge)")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(ScubaTheme.darkText)
                        .padding(.horizontal, 5)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(ScubaTheme.primary)
                        .clipShape(Capsule())
                        .offset(x: 3, y: -3)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(systemImage)
    }
}
