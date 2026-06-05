import Combine
import Foundation

@MainActor
final class SessionStore: ObservableObject {
    enum AuthState: Equatable {
        case restoring
        case signedOut
        case signedIn(User)
    }

    @Published private(set) var authState: AuthState = .restoring

    private let authRepository: any AuthRepositoryProtocol

    init(authRepository: any AuthRepositoryProtocol) {
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
                authState = .signedIn(user)
            } else {
                authState = .signedOut
            }
        } catch {
            AppLogger.log(error, category: AppLogger.auth, context: "Session restore failed")
            authState = .signedOut
        }
    }

    func login(username: String, password: String) async throws {
        let user = try await authRepository.login(username: username, password: password)
        authState = .signedIn(user)
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
        authState = .signedIn(user)
    }

    func logout() async {
        await authRepository.logout()
        authState = .signedOut
    }

    func updateStoredUser(_ user: User) {
        authState = .signedIn(user)
    }
}
