import { ProfileResponse, ProfilesApi, UpsertProfileRequest, UserManagementApi } from "@/api/generated";
import { api, apiConfig, toApiNumberId, unwrap } from "@/services/api";
import { useAuthStore } from "@/store/authStore";
import { ID, User, toUser } from "@/types/models";
import { socialApi } from "@/features/social/socialApi";

const generatedProfilesApi = new ProfilesApi(apiConfig, undefined, api);
const generatedUsersApi = new UserManagementApi(apiConfig, undefined, api);

function currentUserId(): number {
  const id = useAuthStore.getState().user?.id;
  if (id === undefined || id === null) throw new Error("You must be logged in to load this profile.");
  return toApiNumberId(id, "current user id");
}

function userToProfilePatch(input: Partial<User>): UpsertProfileRequest {
  return {
    firstName: input.firstName,
    lastName: input.lastName,
    phoneNumber: input.phoneNumber,
    city: input.city,
    state: input.state,
    country: input.country,
    bio: input.bio,
    diveCount: input.diveCount,
    profileImageUrl: input.profileImageUrl,
    visibilityStatus: "PUBLIC"
  };
}

async function withSocialStats(user: User): Promise<User> {
  try {
    const summary = await socialApi.summary(user.id);
    return {
      ...user,
      followersCount: summary.followerCount ?? 0,
      followingCount: summary.followingCount ?? 0,
      followedByMe: summary.followedByCurrentUser ?? false
    };
  } catch {
    return user;
  }
}

export const profileApi = {
  async me(): Promise<User> {
    const response = await unwrap<ProfileResponse>(generatedProfilesApi.get(currentUserId()));
    const user = { ...useAuthStore.getState().user, ...toUser(response) } as User;
    return withSocialStats(user);
  },

  async updateMe(input: Partial<User>): Promise<User> {
    const response = await unwrap<ProfileResponse>(generatedProfilesApi.update1(currentUserId(), userToProfilePatch(input)));
    const user = { ...useAuthStore.getState().user, ...toUser(response) } as User;
    return withSocialStats(user);
  },

  async user(userId: ID): Promise<User> {
    const apiUserId = toApiNumberId(userId, "user id");
    try {
      const profile = await unwrap<ProfileResponse>(generatedProfilesApi.get(apiUserId));
      return withSocialStats(toUser(profile));
    } catch {
      const user = await unwrap(generatedUsersApi.getById(apiUserId));
      return withSocialStats(toUser(user));
    }
  }
};
