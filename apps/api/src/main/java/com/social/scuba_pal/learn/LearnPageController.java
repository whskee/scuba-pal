package com.social.scuba_pal.learn;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LearnPageController {
    private final LearnService learnService;

    public LearnPageController(LearnService learnService) {
        this.learnService = learnService;
    }

    @GetMapping("/learn")
    public String learn(Model model) {
        model.addAttribute("articles", learnService.getPublishedArticles());
        return "learn/index";
    }
}
