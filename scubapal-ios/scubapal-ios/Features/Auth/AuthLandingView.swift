import SwiftUI

struct AuthLandingView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appUI: AppUIStore
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero
                form
            }
            .padding(.horizontal, 20)
            .padding(.top, 26)
            .padding(.bottom, 38)
        }
        .scrollIndicators(.hidden)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                BrandSignature(tagline: "Ocean social", markSize: 52)
                Spacer()
                Text(viewModel.mode == .login ? "Welcome back" : "New diver")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(ScubaTheme.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(ScubaTheme.primary.opacity(0.12), in: Capsule())
            }

            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 156)
                .padding(.vertical, 2)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text("Scuba Pal")
                    .font(.system(size: 46, weight: .black))
                    .foregroundStyle(ScubaTheme.ink)
                    .minimumScaleFactor(0.75)
                Text("A polished home for dive stories, buddy chat, local shops, learning, and ocean profiles.")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ScubaTheme.muted)
                    .lineSpacing(4)
            }

            HStack(spacing: 10) {
                FeaturePill(title: "Dive feed", systemImage: "square.grid.2x2.fill")
                FeaturePill(title: "Messages", systemImage: "bubble.left.and.bubble.right.fill")
                FeaturePill(title: "Learn", systemImage: "graduationcap.fill")
            }
        }
        .padding(22)
        .glassPanel(radius: 32, fill: ScubaTheme.surface.opacity(0.66), border: ScubaTheme.primary.opacity(0.2))
    }

    private var form: some View {
        VStack(spacing: 14) {
            Picker("Mode", selection: $viewModel.mode) {
                Text("Log in").tag(AuthViewModel.Mode.login)
                Text("Create").tag(AuthViewModel.Mode.register)
            }
            .pickerStyle(.segmented)
            .tint(ScubaTheme.primary)
            .onChange(of: viewModel.mode) { _, _ in viewModel.clearError() }

            if viewModel.mode == .register {
                FloatingTextField(title: "Email", text: $viewModel.email, systemImage: "envelope.fill", keyboardType: .emailAddress, textContentType: .emailAddress)
                    .transition(.move(edge: .top).combined(with: .opacity))
                HStack(spacing: 10) {
                    FloatingTextField(title: "First name", text: $viewModel.firstName, systemImage: "person.fill", textContentType: .givenName)
                    FloatingTextField(title: "Last name", text: $viewModel.lastName, systemImage: "person.text.rectangle.fill", textContentType: .familyName)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            FloatingTextField(title: "Username", text: $viewModel.username, systemImage: "at", textContentType: .username)
            FloatingTextField(title: "Password", text: $viewModel.password, systemImage: "lock.fill", isSecure: true, textContentType: viewModel.mode == .login ? .password : .newPassword)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ScubaTheme.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            ScubaButton(
                title: viewModel.mode == .login ? "Log in" : "Create account",
                systemImage: viewModel.mode == .login ? "arrow.right.circle.fill" : "sparkles",
                isLoading: viewModel.isSubmitting,
                isDisabled: !viewModel.canSubmit,
                action: submit
            )
        }
        .padding(18)
        .glassPanel(radius: 28, fill: ScubaTheme.background.opacity(0.34))
        .animation(.smooth(duration: 0.25), value: viewModel.mode)
    }

    private func submit() {
        Task {
            if let message = await viewModel.submit(session: session) {
                appUI.showToast(message)
            }
        }
    }
}

private struct FeaturePill: View {
    var title: String
    var systemImage: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(title)
                .lineLimit(1)
        }
        .font(.system(size: 12, weight: .heavy))
        .foregroundStyle(ScubaTheme.reef)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(ScubaTheme.lagoon.opacity(0.38), in: Capsule())
        .overlay(Capsule().stroke(ScubaTheme.primary.opacity(0.16), lineWidth: 1))
    }
}
