import { FollowSummaryView, FollowsApi } from "@/api/generated";
import { api, apiConfig, pageParams, PagedResult, toApiNumberId, toPageMeta, unwrap } from "@/services/api";
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
    return unwrap(generatedFollowApi.summary(toApiNumberId(userId, "user id")));
  },

  async follow(userId: ID): Promise<User> {
    const apiUserId = toApiNumberId(userId, "user id");
    const summary = await unwrap(generatedFollowApi.follow(apiUserId));
    return summaryToUser(userId, summary);
  },

  async unfollow(userId: ID): Promise<User> {
    const apiUserId = toApiNumberId(userId, "user id");
    const summary = await unwrap(generatedFollowApi.unfollow(apiUserId));
    return summaryToUser(userId, summary);
  },

  async followersPage(userId: ID, page = 0, size = 20): Promise<PagedResult<User>> {
    const params = pageParams(page, size);
    const response = await unwrap(generatedFollowApi.followers(toApiNumberId(userId, "user id"), params.page, params.size));
    return {
      items: (response.users ?? []).map((user) => toUser(user)),
      page: toPageMeta(response.page)
    };
  },

  async followers(userId: ID, page = 0, size = 20): Promise<User[]> {
    const response = await socialApi.followersPage(userId, page, size);
    return response.items;
  },

  async followingPage(userId: ID, page = 0, size = 20): Promise<PagedResult<User>> {
    const params = pageParams(page, size);
    const response = await unwrap(generatedFollowApi.following(toApiNumberId(userId, "user id"), params.page, params.size));
    return {
      items: (response.users ?? []).map((user) => toUser(user)),
      page: toPageMeta(response.page)
    };
  },

  async following(userId: ID, page = 0, size = 20): Promise<User[]> {
    const response = await socialApi.followingPage(userId, page, size);
    return response.items;
  }
};
