package com.social.scuba_pal.learn;

import com.social.scuba_pal.shared.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class LearnService {
    private final LearnArticleRepository learnArticleRepository;

    public LearnService(LearnArticleRepository learnArticleRepository) {
        this.learnArticleRepository = learnArticleRepository;
    }

    @Transactional(readOnly = true)
    public List<LearnArticleResponse> getPublishedArticles() {
        return learnArticleRepository.findByPublishedTrueOrderByDisplayOrderAscTitleAsc()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public LearnArticleResponse getPublishedArticle(String slug) {
        return learnArticleRepository.findBySlugAndPublishedTrue(slug)
                .map(this::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("Learn article not found: " + slug));
    }

    private LearnArticleResponse toResponse(LearnArticle article) {
        return new LearnArticleResponse(
                article.getId(),
                article.getSlug(),
                article.getTitle(),
                article.getSummary(),
                article.getContent(),
                article.getCategory(),
                article.getDifficultyLevel(),
                article.getEstimatedMinutes(),
                article.getUpdatedAt()
        );
    }
}
