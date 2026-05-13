import { api, unwrap } from "@/services/api";
import { normalizeApiDateString } from "@/utils/date";

export type LearnArticle = {
  id: number;
  slug: string;
  title: string;
  summary: string;
  content: string;
  category: string;
  difficultyLevel: string;
  estimatedMinutes: number;
  updatedAt: string;
};

type LearnArticleResponse = {
  articleId?: number;
  slug?: string;
  title?: string;
  summary?: string;
  content?: string;
  category?: string;
  difficultyLevel?: string;
  estimatedMinutes?: number;
  updatedAt?: string;
};

function toLearnArticle(input: LearnArticleResponse): LearnArticle {
  return {
    id: input.articleId ?? 0,
    slug: input.slug ?? "learn-article",
    title: input.title ?? "Scuba lesson",
    summary: input.summary ?? "",
    content: input.content ?? "",
    category: input.category ?? "Learning",
    difficultyLevel: input.difficultyLevel ?? "Beginner",
    estimatedMinutes: input.estimatedMinutes ?? 5,
    updatedAt: normalizeApiDateString(input.updatedAt ?? new Date().toISOString())
  };
}

export const learnApi = {
  async articles(): Promise<LearnArticle[]> {
    const response = await unwrap<LearnArticleResponse[]>(api.get("/api/learn/articles"));
    return response.map(toLearnArticle);
  }
};
