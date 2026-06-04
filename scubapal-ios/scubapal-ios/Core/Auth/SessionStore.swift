import Combine
import SwiftUI

@MainActor
final class SessionStore: ObservableObject {
    enum AuthState: Equatable {
        case restoring
        case signedOut
        case signedIn(User)
    }

    @Published private(set) var authState: AuthState = .restoring

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    var currentUser: User? {
        if case let .signedIn(user) = authState { return user }
        return nil
    }

    var isAuthenticated: Bool {
        currentUser != nil
    }

    func restore() async {
        do {
            if let user = try await authRepository.restoreCurrentUser() {
                withAnimation(.smooth(duration: 0.45)) { authState = .signedIn(user) }
            } else {
                withAnimation(.smooth(duration: 0.35)) { authState = .signedOut }
            }
        } catch {
            withAnimation(.smooth(duration: 0.35)) { authState = .signedOut }
        }
    }

    func login(username: String, password: String) async throws {
        let user = try await authRepository.login(username: username, password: password)
        withAnimation(.smooth(duration: 0.45)) { authState = .signedIn(user) }
    }

    func register(
        email: String,
        username: String,
        password: String,
        firstName: String?,
        lastName: String?
    ) async throws {
        let user = try await authRepository.register(
            email: email,
            username: username,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        withAnimation(.smooth(duration: 0.45)) { authState = .signedIn(user) }
    }

    func logout() async {
        await authRepository.logout()
        withAnimation(.smooth(duration: 0.35)) { authState = .signedOut }
    }

    func updateStoredUser(_ user: User) {
        withAnimation(.smooth(duration: 0.25)) {
            authState = .signedIn(user)
        }
    }
}
