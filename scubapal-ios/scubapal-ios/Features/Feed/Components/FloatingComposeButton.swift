import SwiftUI

struct FloatingComposeButton: View {
    let user: User?
    let onSubmit: (String, [String]) async -> Void

    @State private var isExpanded = false
    @State private var settledOffset = CGSize.zero
    @State private var dragOffset = CGSize.zero
    @State private var caption = ""
    @State private var mediaURL = ""
    @State private var isSubmitting = false

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .allowsHitTesting(false)
                .overlay(alignment: .bottomTrailing) {
                    composeStack(in: proxy.size)
                        .allowsHitTesting(true)
                }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var currentOffset: CGSize {
        CGSize(
            width: settledOffset.width + dragOffset.width,
            height: settledOffset.height + dragOffset.height
        )
    }

    private func composeStack(in size: CGSize) -> some View {
        ZStack(alignment: .bottomTrailing) {
            if isExpanded {
                FloatingComposePanel(
                    user: user,
                    caption: $caption,
                    mediaURL: $mediaURL,
                    isSubmitting: isSubmitting,
                    onClose: collapse,
                    onSubmit: submit
                )
                .transition(.scale(scale: 0.86, anchor: .bottomTrailing).combined(with: .opacity))
                .padding(.bottom, 74)
            }

            Button(action: toggleExpanded) {
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(ScubaTheme.darkText)
                    .frame(width: 64, height: 64)
                        .background(ScubaTheme.reefGradient, in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.34), lineWidth: 1))
                        .shadow(color: .black.opacity(0.34), radius: 14, x: 0, y: 8)
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel(isExpanded ? "Close post composer" : "Create post")
        }
        .padding(.trailing, 18)
        .padding(.bottom, 96)
        .offset(currentOffset)
        .gesture(
            DragGesture(minimumDistance: 8)
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    settledOffset = clampedOffset(
                        CGSize(
                            width: settledOffset.width + value.translation.width,
                            height: settledOffset.height + value.translation.height
                        ),
                        in: size
                    )
                    dragOffset = .zero
                }
        )
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isExpanded)
    }

    private func toggleExpanded() {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            isExpanded.toggle()
        }
    }

    private func collapse() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            isExpanded = false
        }
    }

    private func submit() {
        guard let caption = caption.nilIfBlank else { return }
        isSubmitting = true
        Task {
            let urls = mediaURL.nilIfBlank.map { [$0] } ?? []
            await onSubmit(caption, urls)
            self.caption = ""
            mediaURL = ""
            isSubmitting = false
            collapse()
        }
    }

    private func clampedOffset(_ offset: CGSize, in size: CGSize) -> CGSize {
        CGSize(
            width: min(0, max(offset.width, -size.width + 96)),
            height: min(0, max(offset.height, -size.height + 220))
        )
    }
}

private struct FloatingComposePanel: View {
    let user: User?
    @Binding var caption: String
    @Binding var mediaURL: String
    let isSubmitting: Bool
    let onClose: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 11) {
                AvatarView(user: user, size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text("New dive note")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(ScubaTheme.ink)
                    Text("Post to the lounge")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(ScubaTheme.primary)
                        .textCase(.uppercase)
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(ScubaTheme.muted)
                        .frame(width: 32, height: 32)
                        .background(ScubaTheme.surface2.opacity(0.72), in: Circle())
                }
                .buttonStyle(ScaleButtonStyle())
            }

            FloatingTextField(title: "Caption", text: $caption, systemImage: "text.quote")
            FloatingTextField(title: "Image URL", text: $mediaURL, systemImage: "photo.fill", keyboardType: .URL)

            ScubaButton(
                title: "Post",
                systemImage: "paperplane.fill",
                isLoading: isSubmitting,
                isDisabled: caption.nilIfBlank == nil,
                action: onSubmit
            )
        }
        .padding(16)
        .frame(width: 318)
        .background(ScubaTheme.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    ScubaTheme.primary.opacity(0.2),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.32), radius: 18, x: 0, y: 10)
    }
}
