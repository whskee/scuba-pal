import { FollowControllerApi, FollowSummaryView, UserView } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";
import { ID, User, toUser } from "@/types/models";

const generatedFollowApi = new FollowControllerApi(apiConfig, undefined, api);

type UserListResponse = {
  users?: UserView[];
  content?: UserView[];
  page?: { totalElements?: number };
};

function summaryToUser(userId: ID, summary: FollowSummaryView): User {
  return {
    id: userId,
    username: "diver",
    followersCount: summary.followerCount ?? 0,
    followingCount: summary.followingCount ?? 0,
    followedByMe: summary.followedByCurrentUser ?? false
  };
}

export const socialApi = {
  async summary(userId: ID): Promise<FollowSummaryView> {
    return unwrap<FollowSummaryView>(api.get(`/api/users/${userId}/follow-summary`));
  },

  async follow(userId: ID): Promise<User> {
    const summary = await unwrap<FollowSummaryView>(generatedFollowApi.follow(Number(userId)));
    return summaryToUser(userId, summary);
  },

  async unfollow(userId: ID): Promise<User> {
    const summary = await unwrap<FollowSummaryView>(generatedFollowApi.unfollow(Number(userId)));
    return summaryToUser(userId, summary);
  },

  async followers(userId: ID, page = 0, size = 20): Promise<User[]> {
    const response = await unwrap<UserListResponse>(api.get(`/api/users/${userId}/followers`, { params: { page, size } }));
    return (response.users ?? response.content ?? []).map((user) => toUser(user));
  },

  async following(userId: ID, page = 0, size = 20): Promise<User[]> {
    const response = await unwrap<UserListResponse>(api.get(`/api/users/${userId}/following`, { params: { page, size } }));
    return (response.users ?? response.content ?? []).map((user) => toUser(user));
  }
};
