import Foundation
import Combine
import SwiftUI

@MainActor
final class AppSession: ObservableObject {
    enum AuthState: Equatable {
        case restoring
        case signedOut
        case signedIn(User)
    }

    @Published private(set) var authState: AuthState = .restoring
    @Published var unreadMessages = 0
    @Published var unreadNotifications = 0
    @Published var toast: ToastState?

    let api: ScubaAPI
    private let tokenVault = TokenVault()

    init(api: ScubaAPI = ScubaAPI()) {
        self.api = api
    }

    var currentUser: User? {
        if case let .signedIn(user) = authState { return user }
        return nil
    }

    var isAuthenticated: Bool {
        currentUser != nil
    }

    func restore() async {
        guard let pair = tokenVault.load() else {
            withAnimation(.smooth(duration: 0.35)) { authState = .signedOut }
            return
        }
        api.tokenPair = pair

        do {
            let view = try await api.currentUser()
            let user = api.toUser(view)
            withAnimation(.smooth(duration: 0.45)) { authState = .signedIn(user) }
            await refreshBadges()
        } catch {
            tokenVault.delete()
            api.tokenPair = nil
            withAnimation(.smooth(duration: 0.35)) { authState = .signedOut }
        }
    }

    func login(username: String, password: String) async throws {
        let response = try await api.login(username: username, password: password)
        try applyAuth(response)
    }

    func register(email: String, username: String, password: String, firstName: String?, lastName: String?) async throws {
        let response = try await api.register(RegisterRequest(email: email, username: username, password: password, firstName: firstName, lastName: lastName))
        try applyAuth(response)
    }

    func logout() async {
        let refreshToken = api.tokenPair?.refreshToken
        await api.logout(refreshToken: refreshToken)
        api.tokenPair = nil
        tokenVault.delete()
        unreadMessages = 0
        unreadNotifications = 0
        withAnimation(.smooth(duration: 0.35)) { authState = .signedOut }
    }

    func updateStoredUser(_ user: User) {
        withAnimation(.smooth(duration: 0.25)) {
            authState = .signedIn(user)
        }
    }

    func refreshBadges() async {
        guard isAuthenticated else { return }
        async let messages = try? api.unreadMessages()
        async let notifications = try? api.unreadNotifications()
        unreadMessages = await messages ?? unreadMessages
        unreadNotifications = await notifications ?? unreadNotifications
    }

    func showToast(_ message: String, systemImage: String = "checkmark.circle.fill") {
        let toast = ToastState(message: message, systemImage: systemImage)
        withAnimation(.snappy(duration: 0.25)) { self.toast = toast }
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.4))
            await MainActor.run {
                guard self?.toast?.id == toast.id else { return }
                withAnimation(.snappy(duration: 0.22)) { self?.toast = nil }
            }
        }
    }

    private func applyAuth(_ response: AuthResponse) throws {
        guard let accessToken = response.accessToken, let refreshToken = response.refreshToken, let userView = response.user else {
            throw APIError.server(message: "The backend did not return a complete session.", status: 500)
        }
        let pair = TokenPair(accessToken: accessToken, refreshToken: refreshToken)
        api.tokenPair = pair
        tokenVault.save(pair)

        let user = api.toUser(userView)
        withAnimation(.smooth(duration: 0.45)) { authState = .signedIn(user) }
        Task { await refreshBadges() }
    }
}

struct ToastState: Identifiable, Equatable {
    let id = UUID()
    var message: String
    var systemImage: String
}

enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)

    var value: Value? {
        if case let .loaded(value) = self { value } else { nil }
    }

    var errorMessage: String? {
        if case let .failed(message) = self { message } else { nil }
    }
}
