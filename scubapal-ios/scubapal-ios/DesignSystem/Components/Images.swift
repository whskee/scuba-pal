import SwiftUI

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
            LinearGradient(
                colors: [ScubaTheme.surface2, ScubaTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
