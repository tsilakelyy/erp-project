package com.erp.controller;

import com.erp.converter.DTOConverter;
import com.erp.domain.Article;
import com.erp.domain.Category;
import com.erp.domain.PricingListLine;
import com.erp.dto.ArticleDTO;
import com.erp.dto.ArticleWithDetailsDTO;
import com.erp.service.ArticleService;
import com.erp.service.CategoryService;
import com.erp.service.PricingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
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

    @Autowired
    private CategoryService categoryService;

    @Autowired(required = false)
    private PricingService pricingService;

    @GetMapping
    public String list(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        // ✅ Charge les articles avec leurs catégories (Article + Catégorie TOUJOURS liés)
        List<Article> articles = articleService.findAllActive();
        model.addAttribute("articles", articles);
        return "articles/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Article> article = articleService.findById(id);
        if (article.isPresent()) {
            model.addAttribute("article", article.get());
            return "articles/detail";
        }
        return "redirect:/articles";
    }

    @GetMapping("/new")
    public String createForm(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        model.addAttribute("article", new Article());
        model.addAttribute("categories", categoryService.findAll());
        return "articles/form";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Article> article = articleService.findById(id);
        if (article.isPresent()) {
            model.addAttribute("article", article.get());
            model.addAttribute("categories", categoryService.findAll());
            return "articles/form";
        }
        return "redirect:/articles";
    }

    @PostMapping
    public String create(@ModelAttribute Article article, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            articleService.createArticle(article, username);
            return "redirect:/articles?success=1";
        } catch (Exception e) {
            return "redirect:/articles/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/{id}/update")
    public String update(@PathVariable Long id, @ModelAttribute Article article, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        article.setId(id);
        try {
            articleService.updateArticle(article, username);
            return "redirect:/articles";
        } catch (Exception e) {
            return "redirect:/articles/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/deactivate")
    public String deactivate(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        articleService.deactivateArticle(id, username);
        return "redirect:/articles";
    }

    // REST API endpoints - Using DTOs
    @GetMapping("/api/all")
    @ResponseBody
    public ResponseEntity<List<ArticleDTO>> getAllArticles() {
        // ✅ Utilise findAllActive() qui retourne findByActifTrueOrderByLibelle()
        return ResponseEntity.ok(
            articleService.findAllActive().stream()
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
    public ResponseEntity<ArticleDTO> createArticleApi(@RequestBody ArticleDTO articleDTO, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            Article article = dtoConverter.dtoToArticle(articleDTO);
            Article saved = articleService.createArticle(article, username);
            return ResponseEntity.status(HttpStatus.CREATED).body(dtoConverter.articleToDTO(saved));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Endpoint de recherche complète : Article + Catégorie + Prix
     * Assure que ces trois éléments sont TOUJOURS liés
     */
    @GetMapping("/api/search")
    @ResponseBody
    public ResponseEntity<List<ArticleWithDetailsDTO>> searchArticles(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false, defaultValue = "VENTE") String priceType) {
        try {
            // Récupère tous les articles avec catégories
            List<Article> articles = articleService.findAllActive();
            
            // Filtre par catégorie si spécifié
            if (categoryId != null) {
                articles = articles.stream()
                    .filter(a -> a.getCategory() != null && a.getCategory().getId().equals(categoryId))
                    .collect(Collectors.toList());
            }
            
            // Filtre par texte si spécifié
            if (query != null && !query.trim().isEmpty()) {
                String needle = query.toLowerCase();
                articles = articles.stream()
                    .filter(a -> a.getLibelle().toLowerCase().contains(needle) ||
                                a.getCode().toLowerCase().contains(needle) ||
                                (a.getDescription() != null && a.getDescription().toLowerCase().contains(needle)) ||
                                (a.getCategory() != null && a.getCategory().getLibelle().toLowerCase().contains(needle)))
                    .collect(Collectors.toList());
            }
            
            // Convertit en DTOs avec les détails de prix
            List<ArticleWithDetailsDTO> result = articles.stream()
                .map(a -> convertArticleToDetailsDTO(a, priceType))
                .collect(Collectors.toList());
            
            // Filtre par prix si spécifié
            if (minPrice != null || maxPrice != null) {
                result = result.stream()
                    .filter(a -> {
                        BigDecimal price = "ACHAT".equals(priceType) ? a.getPrixAchat() : a.getPrixVente();
                        if (price == null) return true; // Inclut les articles sans prix
                        if (minPrice != null && price.compareTo(minPrice) < 0) return false;
                        if (maxPrice != null && price.compareTo(maxPrice) > 0) return false;
                        return true;
                    })
                    .collect(Collectors.toList());
            }
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupère les détails complets d'un article (article + catégorie + prix)
     */
    @GetMapping("/api/{id}/details")
    @ResponseBody
    public ResponseEntity<ArticleWithDetailsDTO> getArticleDetails(@PathVariable Long id) {
        Optional<Article> article = articleService.findById(id);
        if (article.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(convertArticleToDetailsDTO(article.get(), "VENTE"));
    }

    /**
     * Convertit un Article en ArticleWithDetailsDTO avec tous les détails
     */
    private ArticleWithDetailsDTO convertArticleToDetailsDTO(Article article, String priceType) {
        ArticleWithDetailsDTO dto = ArticleWithDetailsDTO.builder()
            .id(article.getId())
            .code(article.getCode())
            .libelle(article.getLibelle())
            .description(article.getDescription())
            .uniteMesure(article.getUniteMesure())
            .prixUnitaire(article.getPrixUnitaire())
            .tauxTva(article.getTauxTva())
            .quantiteMinimale(article.getQuantiteMinimale())
            .quantiteMaximale(article.getQuantiteMaximale())
            .actif(article.getActif())
            .build();

        // Ajoute les informations de catégorie
        if (article.getCategory() != null) {
            Category cat = article.getCategory();
            dto.setCategoryId(cat.getId());
            dto.setCategoryCode(cat.getCode());
            dto.setCategoryLibelle(cat.getLibelle());
            dto.setCategoryDescription(cat.getDescription());
        }

        // Ajoute les informations de prix via le service de pricing si disponible
        if (pricingService != null) {
            try {
                if ("ACHAT".equals(priceType)) {
                    var pricingLine = pricingService.getPricingForArticle(article, "ACHAT");
                    if (pricingLine.isPresent()) {
                        PricingListLine pricing = pricingLine.get();
                        dto.setPrixAchat(pricing.getPrixUnitaire());
                        dto.setRemiseAchat(pricing.getRemisePourcentage());
                        dto.setPrixNetAchat(pricing.getPrixNet());
                    } else {
                        dto.setPrixAchat(article.getPrixUnitaire());
                    }
                } else {
                    var pricingLine = pricingService.getPricingForArticle(article, "VENTE");
                    if (pricingLine.isPresent()) {
                        PricingListLine pricing = pricingLine.get();
                        dto.setPrixVente(pricing.getPrixUnitaire());
                        dto.setRemiseVente(pricing.getRemisePourcentage());
                        dto.setPrixNetVente(pricing.getPrixNet());
                    } else {
                        dto.setPrixVente(article.getPrixUnitaire());
                    }
                }
            } catch (Exception e) {
                // En cas d'erreur, utilise le prix unitaire par défaut
                dto.setPrixVente(article.getPrixUnitaire());
                dto.setPrixAchat(article.getPrixUnitaire());
            }
        } else {
            // Fallback si no pricing service
            dto.setPrixVente(article.getPrixUnitaire());
            dto.setPrixAchat(article.getPrixUnitaire());
        }

        return dto;
    }
}
