import Foundation

struct UserMapper: Sendable {
    func map(_ input: CurrentUserDTO, follow: FollowSummaryDTO? = nil) throws -> User {
        try user(
            id: input.id,
            username: input.username,
            firstName: input.firstName,
            lastName: input.lastName,
            email: input.email,
            city: input.city,
            state: nil,
            country: input.country,
            profileImageUrl: input.profileImageUrl,
            bio: input.bio,
            diveCount: input.diveCount,
            follow: follow
        )
    }

    func map(_ input: PublicProfileDTO, follow: FollowSummaryDTO? = nil) throws -> User {
        try user(
            id: input.userId,
            username: input.username,
            firstName: input.firstName,
            lastName: input.lastName,
            email: nil,
            city: input.city,
            state: nil,
            country: input.country,
            profileImageUrl: input.profileImageUrl,
            bio: input.bio,
            diveCount: input.diveCount,
            follow: follow
        )
    }

    func map(_ input: ProfileDTO, follow: FollowSummaryDTO? = nil) throws -> User {
        try user(
            id: input.userId ?? input.profileId,
            username: input.username,
            firstName: input.firstName,
            lastName: input.lastName,
            email: nil,
            city: input.city,
            state: input.state,
            country: input.country,
            profileImageUrl: input.profileImageUrl,
            bio: input.bio,
            diveCount: input.diveCount,
            follow: follow
        )
    }

    func map(_ input: PublicUserDTO) throws -> User {
        try user(
            id: input.id,
            username: input.username,
            firstName: input.firstName,
            lastName: input.lastName,
            email: nil,
            city: input.city,
            state: nil,
            country: input.country,
            profileImageUrl: input.profileImageUrl,
            bio: input.bio,
            diveCount: input.diveCount,
            follow: nil
        )
    }

    func mapFollowSummary(_ input: FollowSummaryDTO) -> FollowSummary {
        FollowSummary(
            followingCount: input.followingCount ?? 0,
            followerCount: input.followerCount ?? 0,
            followedByCurrentUser: input.followedByCurrentUser ?? false
        )
    }

    private func user(
        id: Int?,
        username: String?,
        firstName: String?,
        lastName: String?,
        email: String?,
        city: String?,
        state: String?,
        country: String?,
        profileImageUrl: String?,
        bio: String?,
        diveCount: Int?,
        follow: FollowSummaryDTO?
    ) throws -> User {
        User(
            id: try RequiredField.value(id, "userId"),
            username: try RequiredField.nonBlank(username, "username"),
            firstName: firstName,
            lastName: lastName,
            email: email,
            city: city,
            state: state,
            country: country,
            profileImageUrl: profileImageUrl,
            bio: bio,
            diveCount: diveCount ?? 0,
            followersCount: follow?.followerCount ?? 0,
            followingCount: follow?.followingCount ?? 0,
            followedByMe: follow?.followedByCurrentUser ?? false
        )
    }
}
