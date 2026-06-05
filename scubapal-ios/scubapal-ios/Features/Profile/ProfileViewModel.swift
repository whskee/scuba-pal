import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: Loadable<User> = .idle
    @Published private(set) var isMutating = false

    private let profileRepository: any ProfileRepositoryProtocol
    private let messagingRepository: any MessagingRepositoryProtocol

    init(
        profileRepository: any ProfileRepositoryProtocol,
        messagingRepository: any MessagingRepositoryProtocol
    ) {
        self.profileRepository = profileRepository
        self.messagingRepository = messagingRepository
    }

    func load(isMine: Bool, userID: Int?, seedUser: User?, currentUser: User?) async {
        if let seedUser, user.value == nil {
            user = .loaded(seedUser)
        } else {
            user = .loading
        }

        do {
            let loaded: User
            if isMine {
                loaded = try await profileRepository.currentProfile()
            } else {
                guard let userID else { throw MappingError.missingRequiredField("userID") }
                loaded = try await profileRepository.profile(userID: userID)
            }
            user = .loaded(loaded)
        } catch {
            if isMine, let currentUser {
                user = .loaded(currentUser)
            } else {
                user = .failed(error.userFacingMessage)
            }
        }
    }

    func follow(_ user: User) async -> String? {
        isMutating = true
        defer { isMutating = false }
        do {
            let summary = try await profileRepository.follow(
                userID: user.id,
                shouldFollow: !user.followedByMe
            )
            var updated = user
            updated.followedByMe = summary.followedByCurrentUser
            updated.followersCount = summary.followerCount
            updated.followingCount = summary.followingCount
            self.user = .loaded(updated)
            return nil
        } catch {
            return error.userFacingMessage
        }
    }

    func startConversation(with user: User) async -> Result<Conversation, Error> {
        isMutating = true
        defer { isMutating = false }
        do {
            return .success(try await messagingRepository.startConversation(userID: user.id))
        } catch {
            return .failure(error)
        }
    }

    func updateProfile(_ update: ProfileUpdate) async -> Result<User, Error> {
        do {
            let updated = try await profileRepository.updateCurrentProfile(update)
            user = .loaded(updated)
            return .success(updated)
        } catch {
            return .failure(error)
        }
    }
}
