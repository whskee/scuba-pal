import { FollowSummaryView, FollowsApi } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";
import { ID, User, toUser } from "@/types/models";

const generatedFollowApi = new FollowsApi(apiConfig, undefined, api);

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
    return unwrap(generatedFollowApi.summary(Number(userId)));
  },

  async follow(userId: ID): Promise<User> {
    const summary = await unwrap(generatedFollowApi.follow(Number(userId)));
    return summaryToUser(userId, summary);
  },

  async unfollow(userId: ID): Promise<User> {
    const summary = await unwrap(generatedFollowApi.unfollow(Number(userId)));
    return summaryToUser(userId, summary);
  },

  async followers(userId: ID, page = 0, size = 20): Promise<User[]> {
    const response = await unwrap(generatedFollowApi.followers(Number(userId), page, size));
    return (response.users ?? []).map((user) => toUser(user));
  },

  async following(userId: ID, page = 0, size = 20): Promise<User[]> {
    const response = await unwrap(generatedFollowApi.following(Number(userId), page, size));
    return (response.users ?? []).map((user) => toUser(user));
  }
};
