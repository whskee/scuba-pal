import { ProfileResponse, ProfilesApi, PublicProfileResponse, UpsertProfileRequest } from "@/api/generated";
import { api, apiConfig, toApiNumberId, unwrap } from "@/services/api";
import { useAuthStore } from "@/store/authStore";
import { ID, User, toUser } from "@/types/models";
import { socialApi } from "@/features/social/socialApi";

const generatedProfilesApi = new ProfilesApi(apiConfig, undefined, api);

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
    const response = await unwrap<ProfileResponse>(generatedProfilesApi.currentProfile());
    const user = { ...useAuthStore.getState().user, ...toUser(response) } as User;
    return withSocialStats(user);
  },

  async updateMe(input: Partial<User>): Promise<User> {
    const response = await unwrap<ProfileResponse>(generatedProfilesApi.updateCurrentProfile(userToProfilePatch(input)));
    const user = { ...useAuthStore.getState().user, ...toUser(response) } as User;
    return withSocialStats(user);
  },

  async user(userId: ID): Promise<User> {
    const apiUserId = toApiNumberId(userId, "user id");
    const profile = await unwrap<PublicProfileResponse>(generatedProfilesApi.get1(apiUserId));
    return withSocialStats(toUser(profile));
  }
};
