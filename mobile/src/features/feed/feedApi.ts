import { CreateCommentRequest, CreateCurrentUserPostRequest, PostsApi } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";
import { ID, Post, toPost } from "@/types/models";

const generatedPostsApi = new PostsApi(apiConfig, undefined, api);

export type CreatePostInput = {
  content: string;
  mediaUrls?: string[];
};

export const feedApi = {
  async feed(page = 0, size = 20): Promise<Post[]> {
    const response = await unwrap(generatedPostsApi.getAll1(page, size));
    return (response.content ?? []).map(toPost);
  },

  async userPosts(userId: ID, page = 0, size = 20): Promise<Post[]> {
    const response = await unwrap(generatedPostsApi.getByUser(Number(userId), page, size));
    return (response.content ?? []).map(toPost);
  },

  async detail(postId: ID): Promise<Post> {
    const response = await unwrap(generatedPostsApi.getById1(Number(postId)));
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
    const response = await unwrap(generatedPostsApi.like(Number(postId)));
    return toPost(response);
  },

  // The current backend contract exposes POST /api/posts/{id}/like only.
  // Treat unlike as the same toggle endpoint until the backend adds DELETE /like.
  async unlike(postId: ID): Promise<Post> {
    const response = await unwrap(generatedPostsApi.like(Number(postId)));
    return toPost(response);
  },

  async comment(postId: ID, body: string): Promise<Post> {
    const payload: CreateCommentRequest = { commentText: body };
    const response = await unwrap(generatedPostsApi.comment(Number(postId), payload));
    return toPost(response);
  }
};
