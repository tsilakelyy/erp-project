package com.erp.controller;

import com.erp.converter.DTOConverter;
import com.erp.domain.Article;
import com.erp.dto.ArticleDTO;
import com.erp.service.ArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/articles")
public class ArticleController {
    @Autowired
    private ArticleService articleService;

    @Autowired
    private DTOConverter dtoConverter;

    @GetMapping
    public String list(Model model, Authentication auth) {
        List<Article> articles = articleService.findAll();
        model.addAttribute("articles", articles);
        model.addAttribute("username", auth.getName());
        return "articles/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth) {
        Optional<Article> article = articleService.findById(id);
        if (article.isPresent()) {
            model.addAttribute("article", article.get());
            model.addAttribute("username", auth.getName());
            return "articles/detail";
        }
        return "redirect:/articles";
    }

    @GetMapping("/new")
    public String createForm(Model model, Authentication auth) {
        model.addAttribute("article", new Article());
        model.addAttribute("username", auth.getName());
        return "articles/form";
    }

    @PostMapping
    public String create(@ModelAttribute Article article, Authentication auth) {
        try {
            articleService.createArticle(article, auth.getName());
            return "redirect:/articles";
        } catch (Exception e) {
            return "redirect:/articles/new?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/update")
    public String update(@PathVariable Long id, @ModelAttribute Article article, Authentication auth) {
        article.setId(id);
        try {
            articleService.updateArticle(article, auth.getName());
            return "redirect:/articles";
        } catch (Exception e) {
            return "redirect:/articles/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/deactivate")
    public String deactivate(@PathVariable Long id, Authentication auth) {
        articleService.deactivateArticle(id, auth.getName());
        return "redirect:/articles";
    }

    // REST API endpoints - Using DTOs
    @GetMapping("/api/all")
    @ResponseBody
    public ResponseEntity<List<ArticleDTO>> getAllArticles() {
        return ResponseEntity.ok(
            articleService.findAllActif().stream()
                .map(dtoConverter::articleToDTO)
                .collect(Collectors.toList())
        );
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<ArticleDTO> getArticle(@PathVariable Long id) {
        Optional<Article> article = articleService.findById(id);
        return article.map(a -> ResponseEntity.ok(dtoConverter.articleToDTO(a)))
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<ArticleDTO> createArticleApi(@RequestBody ArticleDTO articleDTO, Authentication auth) {
        try {
            Article article = dtoConverter.dtoToArticle(articleDTO);
            Article saved = articleService.createArticle(article, auth.getName());
            return ResponseEntity.status(HttpStatus.CREATED).body(dtoConverter.articleToDTO(saved));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
