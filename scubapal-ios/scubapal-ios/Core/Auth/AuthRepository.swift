import Foundation

protocol AuthRepositoryProtocol: Sendable {
    func restoreCurrentUser() async throws -> User?
    func login(username: String, password: String) async throws -> User
    func register(email: String, username: String, password: String, firstName: String?, lastName: String?) async throws -> User
    func logout() async
    func currentUser() async throws -> User
}

struct AuthRepository: Sendable {
    let apiClient: APIClient
    let tokenStore: any TokenStore
    let userMapper: UserMapper

    func restoreCurrentUser() async throws -> User? {
        guard let pair = try tokenStore.load() else { return nil }
        await apiClient.setTokenPair(pair)
        do {
            return try await currentUser()
        } catch {
            AppLogger.log(error, category: AppLogger.auth, context: "Stored session restore failed; clearing local session")
            await apiClient.setTokenPair(nil)
            try? tokenStore.delete()
            throw error
        }
    }

    func login(username: String, password: String) async throws -> User {
        let endpoint = Endpoint(path: APIPath.login, method: .post, requiresAuth: false)
        let response: AuthResponse = try await apiClient.request(
            endpoint,
            body: LoginRequest(username: username, password: password)
        )
        return try await applyAuth(response)
    }

    func register(
        email: String,
        username: String,
        password: String,
        firstName: String?,
        lastName: String?
    ) async throws -> User {
        let endpoint = Endpoint(path: APIPath.register, method: .post, requiresAuth: false)
        let response: AuthResponse = try await apiClient.request(
            endpoint,
            body: RegisterRequest(
                email: email,
                username: username,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
        )
        return try await applyAuth(response)
    }

    func logout() async {
        if let refreshToken = await apiClient.currentTokenPair()?.refreshToken {
            let endpoint = Endpoint(path: APIPath.logout, method: .post, requiresAuth: false)
            do {
                try await apiClient.requestNoContent(
                    endpoint,
                    body: RefreshTokenRequest(refreshToken: refreshToken)
                )
            } catch {
                AppLogger.log(error, category: AppLogger.auth, context: "Remote logout failed; clearing local session")
            }
        }
        await apiClient.setTokenPair(nil)
        try? tokenStore.delete()
    }

    func currentUser() async throws -> User {
        let response: CurrentUserDTO = try await apiClient.request(Endpoint(path: APIPath.currentUser))
        return try userMapper.map(response)
    }

    private func applyAuth(_ response: AuthResponse) async throws -> User {
        guard
            let accessToken = response.accessToken,
            let refreshToken = response.refreshToken,
            let userDTO = response.user
        else {
            let error = APIError.server(message: "The backend did not return a complete session.", status: 500)
            AppLogger.log(error, category: AppLogger.auth, context: "Auth response missing required session fields")
            throw error
        }

        let pair = TokenPair(accessToken: accessToken, refreshToken: refreshToken)
        try tokenStore.save(pair)
        await apiClient.setTokenPair(pair)
        return try userMapper.map(userDTO)
    }
}

extension AuthRepository: AuthRepositoryProtocol {}
