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
            .padding(.top, 18)
            .padding(.bottom, 38)
        }
        .scrollIndicators(.hidden)
    }

    private var hero: some View {
        ZStack(alignment: .topLeading) {
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .opacity(0.18)
                .frame(maxWidth: .infinity)
                .offset(x: 74, y: 12)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center) {
                    BrandSignature(tagline: "Ocean social", markSize: 52)
                    Spacer()
                    Text(viewModel.mode == .login ? "Welcome back" : "Join the crew")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(ScubaTheme.darkText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(ScubaTheme.primary, in: Capsule())
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Scuba Pal")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(ScubaTheme.ink)
                        .minimumScaleFactor(0.72)
                    Text("Dive stories, buddy chat, local intel, and profile momentum in one sharp flow.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(ScubaTheme.muted)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 10) {
                    AuthMetric(value: "Live", label: "feed")
                    AuthMetric(value: "Fast", label: "chat")
                    AuthMetric(value: "Local", label: "intel")
                }
            }
        }
        .padding(22)
        .frame(minHeight: 292, alignment: .top)
        .glassPanel(radius: 34, fill: ScubaTheme.surface.opacity(0.6), border: ScubaTheme.primary.opacity(0.24))
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 16) {
            AuthModeToggle(mode: $viewModel.mode)
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

            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(ScubaTheme.primary)
                Text(viewModel.mode == .login ? "Secure session restore is enabled." : "Your profile opens the app immediately.")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(ScubaTheme.muted)
                    .lineLimit(2)
            }
        }
        .padding(18)
        .glassPanel(radius: 28, fill: ScubaTheme.background.opacity(0.38), border: ScubaTheme.primary.opacity(0.18))
        .animation(.smooth(duration: 0.25), value: viewModel.mode)
        .animation(.snappy(duration: 0.2), value: viewModel.errorMessage)
    }

    private func submit() {
        Task {
            if let message = await viewModel.submit(session: session) {
                appUI.showToast(message)
            }
        }
    }
}

private struct AuthMetric: View {
    var value: String
    var label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(ScubaTheme.ink)
            Text(label)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(ScubaTheme.primary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(ScubaTheme.background.opacity(0.34), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(ScubaTheme.primary.opacity(0.14), lineWidth: 1))
    }
}

private struct AuthModeToggle: View {
    @Binding var mode: AuthViewModel.Mode
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 6) {
            toggleButton(title: "Log in", systemImage: "person.crop.circle.fill", value: .login)
            toggleButton(title: "Create", systemImage: "sparkles", value: .register)
        }
        .padding(6)
        .background(ScubaTheme.surface.opacity(0.74), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(ScubaTheme.border, lineWidth: 1))
    }

    private func toggleButton(title: String, systemImage: String, value: AuthViewModel.Mode) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.24)) {
                mode = value
            }
        } label: {
            Label(title, systemImage: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(mode == value ? ScubaTheme.darkText : ScubaTheme.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background {
                    if mode == value {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(ScubaTheme.primary)
                            .matchedGeometryEffect(id: "auth-mode", in: namespace)
                    }
                }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
