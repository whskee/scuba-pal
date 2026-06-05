import Foundation

protocol ProfileRepositoryProtocol: Sendable {
    func profiles(query: String) async throws -> [User]
    func profile(userID: Int) async throws -> User
    func currentProfile() async throws -> User
    func updateCurrentProfile(_ update: ProfileUpdate) async throws -> User
    func follow(userID: Int, shouldFollow: Bool) async throws -> FollowSummary
}

struct ProfileRepository: Sendable {
    let apiClient: APIClient
    let mapper: UserMapper

    func profiles(query: String) async throws -> [User] {
        let endpoint = Endpoint(
            path: APIPath.profiles,
            query: PageRequest(size: 50).queryParameters(adding: ["q": query])
        )
        let response: PageResponseDTO<PublicProfileDTO> = try await apiClient.request(endpoint)
        return try (response.content ?? []).map { try mapper.map($0) }
    }

    func profile(userID: Int) async throws -> User {
        async let profileResponse: PublicProfileDTO = apiClient.request(
            Endpoint(path: APIPath.userProfile(userID: userID))
        )
        async let summaryResponse: FollowSummaryDTO? = try? apiClient.request(
            Endpoint(path: APIPath.userFollowSummary(userID: userID))
        )
        return try mapper.map(try await profileResponse, follow: await summaryResponse)
    }

    func currentProfile() async throws -> User {
        let response: ProfileDTO = try await apiClient.request(Endpoint(path: APIPath.currentUserProfile))
        let initial = try mapper.map(response)
        let summary: FollowSummaryDTO? = try? await apiClient.request(
            Endpoint(path: APIPath.userFollowSummary(userID: initial.id))
        )
        return try mapper.map(response, follow: summary)
    }

    func updateCurrentProfile(_ update: ProfileUpdate) async throws -> User {
        let endpoint = Endpoint(path: APIPath.currentUserProfile, method: .put)
        let response: ProfileDTO = try await apiClient.request(
            endpoint,
            body: UpdateProfileRequest(
                firstName: update.firstName,
                lastName: update.lastName,
                phoneNumber: update.phoneNumber,
                city: update.city,
                state: update.state,
                country: update.country,
                bio: update.bio,
                diveCount: update.diveCount,
                profileImageUrl: update.profileImageUrl
            )
        )
        return try mapper.map(response)
    }

    func follow(userID: Int, shouldFollow: Bool) async throws -> FollowSummary {
        let endpoint = Endpoint(
            path: APIPath.userFollow(userID: userID),
            method: shouldFollow ? .post : .delete
        )
        let response: FollowSummaryDTO = try await apiClient.request(endpoint)
        return mapper.mapFollowSummary(response)
    }
}

extension ProfileRepository: ProfileRepositoryProtocol {}
