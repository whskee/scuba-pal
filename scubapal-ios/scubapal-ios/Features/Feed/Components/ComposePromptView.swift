import SwiftUI

struct ComposePromptView: View {
    let user: User?
    let onCompose: () -> Void

    var body: some View {
        Button(action: onCompose) {
            HStack(spacing: 12) {
                AvatarView(user: user, size: 42)
                Text("Share a dive moment...")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(ScubaTheme.muted)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(ScubaTheme.primary)
            }
            .padding(14)
            .glassPanel(radius: 24, fill: ScubaTheme.background.opacity(0.32))
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 18)
    }
}
