import SwiftUI

struct RemoteImage: View {
    var url: URL?
    var cornerRadius: CGFloat = 24
    var contentMode: ContentMode = .fill

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: nil)) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                placeholder(systemImage: "photo")
            case .empty:
                placeholder(systemImage: "waveform.path.ecg")
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
            if let url = user?.profileImageURL ?? user.flatMap({ URL(string: $0.profileImageUrl ?? "") }) {
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
        .shadow(color: ScubaTheme.primary.opacity(size > 40 ? 0.14 : 0), radius: size > 40 ? 8 : 0, x: 0, y: 5)
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
