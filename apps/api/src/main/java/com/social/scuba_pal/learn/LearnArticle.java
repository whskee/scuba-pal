package com.social.scuba_pal.learn;

import com.social.scuba_pal.shared.domain.AuditableEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@AttributeOverride(name = "id", column = @Column(name = "learn_article_id"))
@Table(schema = "learn", name = "articles")
public class LearnArticle extends AuditableEntity {

    @Column(nullable = false, unique = true, length = 140)
    private String slug;

    @Column(nullable = false, length = 180)
    private String title;

    @Column(nullable = false, length = 600)
    private String summary;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(nullable = false, length = 80)
    private String category;

    @Column(name = "difficulty_level", nullable = false, length = 40)
    private String difficultyLevel;

    @Column(name = "estimated_minutes", nullable = false)
    private Integer estimatedMinutes;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @Column(name = "is_published", nullable = false)
    private boolean published = true;
}
