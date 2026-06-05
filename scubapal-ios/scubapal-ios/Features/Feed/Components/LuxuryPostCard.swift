import SwiftUI

struct LuxuryPostCard: View, Equatable {
    let post: Post
    let index: Int
    let onLike: (Post) -> Void
    let onSave: () -> Void

    @State private var saved = false

    private var imageHeight: CGFloat {
        174 + CGFloat((index * 41) % 86)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(value: post) {
                VStack(alignment: .leading, spacing: 0) {
                    cardImage
                    cardBody
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(cardBorder)
                .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 8)
            }
            .buttonStyle(ScaleButtonStyle())

            actionCluster
                .padding(10)
        }
    }

    private var cardImage: some View {
        RemoteImage(url: post.imageUrl, cornerRadius: 0)
            .frame(height: post.imageUrl == nil ? 132 : imageHeight)
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.46)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 72)
            }
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.content.isEmpty ? "Ocean moment" : post.content)
                .font(.system(size: 13.5, weight: .black))
                .foregroundStyle(ScubaTheme.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.9)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            authorLine
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ScubaTheme.luxurySurfaceGradient)
    }

    private var authorLine: some View {
        HStack(spacing: 7) {
            AvatarView(user: post.author, size: 25)
            Text("@\(post.author.username)")
                .font(.system(size: 11.5, weight: .heavy))
                .foregroundStyle(ScubaTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Spacer(minLength: 3)
            Label("\(post.likeCount)", systemImage: post.likedByMe ? "heart.fill" : "heart")
                .font(.system(size: 10.5, weight: .black))
                .foregroundStyle(post.likedByMe ? ScubaTheme.accent : ScubaTheme.muted)
                .labelStyle(.titleAndIcon)
        }
    }

    private var actionCluster: some View {
        HStack(spacing: 8) {
            floatingAction(
                systemImage: post.likedByMe ? "heart.fill" : "heart",
                active: post.likedByMe,
                color: ScubaTheme.accent
            ) {
                onLike(post)
            }
            floatingAction(
                systemImage: saved ? "bookmark.fill" : "bookmark",
                active: saved,
                color: ScubaTheme.secondary
            ) {
                withAnimation(.snappy(duration: 0.22)) {
                    saved.toggle()
                }
                onSave()
            }
        }
    }

    static func == (lhs: LuxuryPostCard, rhs: LuxuryPostCard) -> Bool {
        lhs.index == rhs.index
            && lhs.post.id == rhs.post.id
            && lhs.post.content == rhs.post.content
            && lhs.post.imageUrl == rhs.post.imageUrl
            && lhs.post.author == rhs.post.author
            && lhs.post.likeCount == rhs.post.likeCount
            && lhs.post.likedByMe == rhs.post.likedByMe
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.18),
                        ScubaTheme.primary.opacity(0.16),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    private func floatingAction(systemImage: String, active: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(active ? color : ScubaTheme.ink)
                .frame(width: 34, height: 34)
                .background(.ultraThinMaterial, in: Circle())
                .background(ScubaTheme.background.opacity(0.32), in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(active ? 0.24 : 0.12), lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
