package com.scubapal.learn;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LearnArticleRepository extends JpaRepository<LearnArticle, Long> {
    List<LearnArticle> findByPublishedTrueOrderByDisplayOrderAscTitleAsc();

    Optional<LearnArticle> findBySlugAndPublishedTrue(String slug);
}
