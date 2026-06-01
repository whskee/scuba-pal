import { CreateCommentRequest, CreateCurrentUserPostRequest, PostsApi } from "@/api/generated";
import { api, apiConfig, pageParams, PagedResult, toApiNumberId, toPageMeta, unwrap } from "@/services/api";
import { ID, Post, toPost } from "@/types/models";

const generatedPostsApi = new PostsApi(apiConfig, undefined, api);

export type CreatePostInput = {
  content: string;
  mediaUrls?: string[];
};

export const feedApi = {
  async feedPage(page = 0, size = 20): Promise<PagedResult<Post>> {
    const params = pageParams(page, size);
    const response = await unwrap(generatedPostsApi.getAll3(params.page, params.size));
    return {
      items: (response.content ?? []).map(toPost),
      page: toPageMeta(response.meta)
    };
  },

  async feed(page = 0, size = 20): Promise<Post[]> {
    const response = await feedApi.feedPage(page, size);
    return response.items;
  },

  async userPostsPage(userId: ID, page = 0, size = 20): Promise<PagedResult<Post>> {
    const params = pageParams(page, size);
    const response = await unwrap(generatedPostsApi.getByUser(toApiNumberId(userId, "user id"), params.page, params.size));
    return {
      items: (response.content ?? []).map(toPost),
      page: toPageMeta(response.meta)
    };
  },

  async userPosts(userId: ID, page = 0, size = 20): Promise<Post[]> {
    const response = await feedApi.userPostsPage(userId, page, size);
    return response.items;
  },

  async detail(postId: ID): Promise<Post> {
    const response = await unwrap(generatedPostsApi.getById(toApiNumberId(postId, "post id")));
    return toPost(response);
  },

  async create(input: CreatePostInput): Promise<Post> {
    const payload: CreateCurrentUserPostRequest = {
      caption: input.content,
      visibilityStatus: "PUBLIC",
      mediaUrls: input.mediaUrls ?? []
    };
    const response = await unwrap(generatedPostsApi.createForCurrentUser(payload));
    return toPost(response);
  },

  async like(postId: ID): Promise<Post> {
    const response = await unwrap(generatedPostsApi.like(toApiNumberId(postId, "post id")));
    return toPost(response);
  },

  // The current backend contract exposes POST /api/posts/{id}/like only.
  // Treat unlike as the same toggle endpoint until the backend adds DELETE /like.
  async unlike(postId: ID): Promise<Post> {
    const response = await unwrap(generatedPostsApi.like(toApiNumberId(postId, "post id")));
    return toPost(response);
  },

  async comment(postId: ID, body: string): Promise<Post> {
    const commentText = body.trim();
    const payload: CreateCommentRequest = { commentText };
    const response = await unwrap(generatedPostsApi.comment(toApiNumberId(postId, "post id"), payload));
    return toPost(response);
  }
};
