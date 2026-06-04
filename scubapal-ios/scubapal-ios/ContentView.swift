import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSession

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

            if let toast = session.toast {
                ToastView(toast: toast)
                    .padding(.top, 12)
                    .padding(.horizontal, 18)
                    .zIndex(10)
            }
        }
        .appBackground()
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

struct AuthLandingView: View {
    @EnvironmentObject private var session: AppSession
    @State private var mode: AuthMode = .login
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private enum AuthMode {
        case login
        case register
    }

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
                Text(mode == .login ? "Welcome back" : "New diver")
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
            Picker("Mode", selection: $mode) {
                Text("Log in").tag(AuthMode.login)
                Text("Create").tag(AuthMode.register)
            }
            .pickerStyle(.segmented)
            .tint(ScubaTheme.primary)
            .onChange(of: mode) { _, _ in
                withAnimation(.smooth(duration: 0.25)) { errorMessage = nil }
            }

            if mode == .register {
                FloatingTextField(title: "Email", text: $email, systemImage: "envelope.fill", keyboardType: .emailAddress, textContentType: .emailAddress)
                    .transition(.move(edge: .top).combined(with: .opacity))
                HStack(spacing: 10) {
                    FloatingTextField(title: "First name", text: $firstName, systemImage: "person.fill", textContentType: .givenName)
                    FloatingTextField(title: "Last name", text: $lastName, systemImage: "person.text.rectangle.fill", textContentType: .familyName)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            FloatingTextField(title: "Username", text: $username, systemImage: "at", textContentType: .username)
            FloatingTextField(title: "Password", text: $password, systemImage: "lock.fill", isSecure: true, textContentType: mode == .login ? .password : .newPassword)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ScubaTheme.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            ScubaButton(
                title: mode == .login ? "Log in" : "Create account",
                systemImage: mode == .login ? "arrow.right.circle.fill" : "sparkles",
                isLoading: isSubmitting,
                isDisabled: !canSubmit,
                action: submit
            )
        }
        .padding(18)
        .glassPanel(radius: 28, fill: ScubaTheme.background.opacity(0.34))
        .animation(.smooth(duration: 0.25), value: mode)
    }

    private var canSubmit: Bool {
        let basics = !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && password.count >= 4
        if mode == .login { return basics && !isSubmitting }
        return basics && email.contains("@") && !isSubmitting
    }

    private func submit() {
        errorMessage = nil
        isSubmitting = true

        Task {
            do {
                switch mode {
                case .login:
                    try await session.login(username: username.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
                case .register:
                    try await session.register(
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password,
                        firstName: firstName.nilIfBlank,
                        lastName: lastName.nilIfBlank
                    )
                }
                session.showToast(mode == .login ? "Welcome back" : "Account created")
            } catch {
                withAnimation(.snappy(duration: 0.2)) {
                    errorMessage = error.localizedDescription
                }
            }
            isSubmitting = false
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

extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

#Preview {
    RootView()
        .environmentObject(AppSession())
}
