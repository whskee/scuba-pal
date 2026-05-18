package com.scubapal.learn;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Learn", description = "Endpoints for scuba education content")
@RestController
@RequestMapping("/api/learn")
public class LearnController {
    private final LearnService learnService;

    public LearnController(LearnService learnService) {
        this.learnService = learnService;
    }

    @GetMapping("/articles")
    @Operation(summary = "List learn articles", description = "Returns published scuba education articles.")
    public List<LearnArticleResponse> articles() {
        return learnService.getPublishedArticles();
    }

    @GetMapping("/articles/{slug}")
    @Operation(summary = "Get learn article", description = "Returns one published scuba education article by slug.")
    public LearnArticleResponse article(@PathVariable String slug) {
        return learnService.getPublishedArticle(slug);
    }
}
