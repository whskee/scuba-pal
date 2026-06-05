import SwiftUI

struct ComposePromptView: View {
    let user: User?
    let onCompose: () -> Void

    var body: some View {
        Button(action: onCompose) {
            HStack(spacing: 12) {
                AvatarView(user: user, size: 42)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Log a dive")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(ScubaTheme.ink)
                    Text("Share a moment from below the surface")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(ScubaTheme.muted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
                Spacer()
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(ScubaTheme.darkText)
                    .frame(width: 42, height: 42)
                    .background(ScubaTheme.reefGradient, in: Circle())
                    .shadow(color: ScubaTheme.primary.opacity(0.32), radius: 14, x: 0, y: 8)
            }
            .padding(14)
            .glassPanel(radius: 26, fill: ScubaTheme.surface.opacity(0.6), border: ScubaTheme.primary.opacity(0.16))
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 18)
    }
}
