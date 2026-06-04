import SwiftUI

enum ScubaTheme {
    static let background = Color(red: 0.021, green: 0.056, blue: 0.108)
    static let background2 = Color(red: 0.035, green: 0.102, blue: 0.158)
    static let surface = Color(red: 0.055, green: 0.137, blue: 0.211)
    static let surface2 = Color(red: 0.071, green: 0.211, blue: 0.307)
    static let lagoon = Color(red: 0.033, green: 0.588, blue: 0.651)
    static let reef = Color(red: 0.753, green: 0.949, blue: 0.925)
    static let ink = Color(red: 0.965, green: 0.984, blue: 1.0)
    static let muted = Color(red: 0.66, green: 0.73, blue: 0.79)
    static let primary = Color(red: 0.082, green: 0.82, blue: 0.761)
    static let secondary = Color(red: 0.471, green: 0.651, blue: 1.0)
    static let accent = Color(red: 1.0, green: 0.419, blue: 0.506)
    static let sand = Color(red: 1.0, green: 0.863, blue: 0.659)
    static let danger = Color(red: 1.0, green: 0.42, blue: 0.42)
    static let border = Color.white.opacity(0.12)
    static let darkText = Color(red: 0.063, green: 0.126, blue: 0.2)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                background,
                Color(red: 0.041, green: 0.122, blue: 0.175),
                Color(red: 0.02, green: 0.077, blue: 0.137)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var reefGradient: LinearGradient {
        LinearGradient(
            colors: [primary, reef, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    ScubaTheme.backgroundGradient.ignoresSafeArea()
                    LinearGradient(
                        colors: [
                            ScubaTheme.primary.opacity(0.18),
                            Color.clear,
                            ScubaTheme.accent.opacity(0.08),
                            ScubaTheme.secondary.opacity(0.09)
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

struct BrandMarkView: View {
    var size: CGFloat = 58
    var framed = true

    var body: some View {
        Image("BrandMark")
            .resizable()
            .scaledToFit()
            .padding(framed ? size * 0.12 : 0)
            .frame(width: size, height: size)
            .background {
                if framed {
                    RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                        .fill(ScubaTheme.surface.opacity(0.72))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                                .stroke(ScubaTheme.primary.opacity(0.24), lineWidth: 1)
                        )
                }
            }
            .shadow(color: ScubaTheme.primary.opacity(0.18), radius: 16, x: 0, y: 10)
            .accessibilityHidden(true)
    }
}

struct BrandSignature: View {
    var tagline: String? = nil
    var markSize: CGFloat = 48

    var body: some View {
        HStack(spacing: 11) {
            BrandMarkView(size: markSize)
            VStack(alignment: .leading, spacing: 2) {
                Text("Scuba Pal")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(ScubaTheme.ink)
                    .lineLimit(1)
                if let tagline {
                    Text(tagline)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(ScubaTheme.primary)
                        .textCase(.uppercase)
                        .lineLimit(1)
                }
            }
        }
    }
}

struct BrandedScreenHeader<Accessory: View>: View {
    var title: String
    var eyebrow: String
    var subtitle: String
    var systemImage: String
    let accessory: Accessory

    init(
        title: String,
        eyebrow: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.eyebrow = eyebrow
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.accessory = accessory()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 12) {
                BrandSignature(tagline: eyebrow, markSize: 46)
                Spacer(minLength: 10)
                accessory
            }

            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text(title)
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(ScubaTheme.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                } icon: {
                    Image(systemName: systemImage)
                        .font(.system(size: 19, weight: .black))
                        .foregroundStyle(ScubaTheme.primary)
                }
                .labelStyle(.titleAndIcon)

                Text(subtitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ScubaTheme.muted)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .glassPanel(radius: 30, fill: ScubaTheme.surface.opacity(0.68), border: ScubaTheme.primary.opacity(0.18))
        .padding(.horizontal, 18)
    }
}

extension BrandedScreenHeader where Accessory == EmptyView {
    init(title: String, eyebrow: String, subtitle: String, systemImage: String) {
        self.init(title: title, eyebrow: eyebrow, subtitle: subtitle, systemImage: systemImage) {
            EmptyView()
        }
    }
}

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
    func glassPanel(radius: CGFloat = 28, fill: Color = ScubaTheme.surface.opacity(0.82), border: Color = ScubaTheme.border) -> some View {
        modifier(GlassPanel(radius: radius, fill: fill, border: border))
    }
}

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

struct FloatingTextField: View {
    var title: String
    @Binding var text: String
    var systemImage: String
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(ScubaTheme.primary)
                .frame(width: 22)
            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .foregroundStyle(ScubaTheme.ink)
            .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(ScubaTheme.surface.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(ScubaTheme.border, lineWidth: 1)
        )
    }
}

struct RemoteImage: View {
    var url: URL?
    var cornerRadius: CGFloat = 24
    var contentMode: ContentMode = .fill

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .smooth(duration: 0.35))) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity.combined(with: .scale(scale: 1.025)))
            case .failure:
                placeholder(systemImage: "photo")
            case .empty:
                ZStack {
                    placeholder(systemImage: "waveform.path.ecg")
                    ProgressView()
                        .tint(ScubaTheme.primary)
                }
            @unknown default:
                placeholder(systemImage: "photo")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private func placeholder(systemImage: String) -> some View {
        ZStack {
            LinearGradient(colors: [ScubaTheme.surface2, ScubaTheme.surface], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(ScubaTheme.primary.opacity(0.85))
        }
    }
}

struct AvatarView: View {
    var user: User?
    var size: CGFloat = 52

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [ScubaTheme.primary, ScubaTheme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle()
                .fill(ScubaTheme.background)
                .padding(2.5)
            if let url = user.flatMap({ URL(string: $0.profileImageUrl ?? "") }) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        initials
                    }
                }
                .clipShape(Circle())
                .padding(4)
            } else {
                initials
            }
        }
        .frame(width: size, height: size)
        .shadow(color: ScubaTheme.primary.opacity(0.18), radius: 12, x: 0, y: 8)
    }

    private var initials: some View {
        Text(initialsText)
            .font(.system(size: size * 0.34, weight: .black))
            .foregroundStyle(ScubaTheme.ink)
    }

    private var initialsText: String {
        let source = user?.displayName.replacingOccurrences(of: "@", with: "") ?? "D"
        let pieces = source.split(separator: " ")
        let chars = pieces.prefix(2).compactMap(\.first)
        return chars.isEmpty ? "D" : String(chars).uppercased()
    }
}

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

extension Date {
    func relativeShort() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
