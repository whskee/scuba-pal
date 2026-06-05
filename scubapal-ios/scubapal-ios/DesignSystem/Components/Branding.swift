import SwiftUI

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
                Text("ScubaPal")
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
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(ScubaTheme.primary)
                .frame(width: 38, height: 38)
                .background(ScubaTheme.surface.opacity(0.64), in: Circle())
                .overlay(Circle().stroke(ScubaTheme.primary.opacity(0.18), lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(ScubaTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(subtitle.isEmpty ? eyebrow : subtitle)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(ScubaTheme.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            Spacer(minLength: 10)
            accessory
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
    }
}

extension BrandedScreenHeader where Accessory == EmptyView {
    init(title: String, eyebrow: String, subtitle: String, systemImage: String) {
        self.init(title: title, eyebrow: eyebrow, subtitle: subtitle, systemImage: systemImage) {
            EmptyView()
        }
    }
}
