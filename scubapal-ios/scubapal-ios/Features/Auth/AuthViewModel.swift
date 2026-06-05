import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    enum Mode {
        case login
        case register
    }

    @Published var mode: Mode = .login
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage: String?

    var canSubmit: Bool {
        let basics = username.nilIfBlank != nil && password.count >= 4
        if mode == .login { return basics && !isSubmitting }
        return basics && email.contains("@") && !isSubmitting
    }

    func clearError() {
        errorMessage = nil
    }

    func submit(session: SessionStore) async -> String? {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            switch mode {
            case .login:
                try await session.login(
                    username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                return "Welcome back"
            case .register:
                try await session.register(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password,
                    firstName: firstName.nilIfBlank,
                    lastName: lastName.nilIfBlank
                )
                return "Account created"
            }
        } catch {
            AppLogger.log(error, category: AppLogger.auth, context: "Authentication submission failed")
            errorMessage = error.userFacingMessage
            return nil
        }
    }
}
