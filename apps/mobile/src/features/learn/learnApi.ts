import { LearnApi, LearnArticleResponse } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";
import { normalizeApiDateString } from "@/utils/date";

const generatedLearnApi = new LearnApi(apiConfig, undefined, api);

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
    const response = await unwrap(generatedLearnApi.articles());
    return response.map(toLearnArticle);
  },

  async article(slug: string): Promise<LearnArticle> {
    const response = await unwrap(generatedLearnApi.article(slug));
    return toLearnArticle(response);
  }
};
