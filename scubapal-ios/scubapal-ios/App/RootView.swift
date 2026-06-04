import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var badges: BadgeStore
    @EnvironmentObject private var appUI: AppUIStore

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch session.authState {
                case .restoring:
                    RestoreView()
                case .signedOut:
                    AuthLandingView()
                case .signedIn:
                    AppShellView()
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.985)))

            if let toast = appUI.toast {
                ToastView(toast: toast)
                    .padding(.top, 12)
                    .padding(.horizontal, 18)
                    .zIndex(10)
            }
        }
        .appBackground()
        .onChange(of: session.authState) { _, state in
            if state == .signedOut { badges.reset() }
        }
    }
}

private struct RestoreView: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(ScubaTheme.primary.opacity(0.18), lineWidth: 16)
                    .scaleEffect(pulse ? 1.22 : 0.82)
                    .opacity(pulse ? 0 : 1)
                BrandMarkView(size: 94)
            }
            .frame(width: 120, height: 120)

            Text("Scuba Pal")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(ScubaTheme.ink)
            Text("Syncing your dive circle")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ScubaTheme.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.45).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.live
    RootView()
        .environmentObject(SessionStore(authRepository: environment.authRepository))
        .environmentObject(
            BadgeStore(
                messagingRepository: environment.messagingRepository,
                notificationsRepository: environment.notificationsRepository
            )
        )
        .environmentObject(AppUIStore())
}
