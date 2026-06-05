import SwiftUI

struct CreatePostSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var caption = ""
    @State private var mediaURL = ""
    @State private var isSubmitting = false

    let onSubmit: (String, [String]) async -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                FloatingTextField(title: "Caption", text: $caption, systemImage: "text.quote")
                FloatingTextField(title: "Image URL", text: $mediaURL, systemImage: "photo.fill", keyboardType: .URL)
                Text("Image upload can be added on top of the backend media upload contract; URL posting is supported now.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ScubaTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                ScubaButton(title: "Post", systemImage: "paperplane.fill", isLoading: isSubmitting, isDisabled: caption.nilIfBlank == nil) {
                    submit()
                }
            }
            .padding(20)
            .appBackground()
            .navigationTitle("New post")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func submit() {
        guard let caption = caption.nilIfBlank else { return }
        isSubmitting = true
        Task {
            let urls = mediaURL.nilIfBlank.map { [$0] } ?? []
            await onSubmit(caption, urls)
            isSubmitting = false
            dismiss()
        }
    }
}
