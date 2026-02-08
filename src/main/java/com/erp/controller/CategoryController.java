package com.erp.controller;

import com.erp.domain.Article;
import com.erp.domain.Category;
import com.erp.domain.User;
import com.erp.dto.CategoryDTO;
import com.erp.service.ArticleService;
import com.erp.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin/categories")
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private ArticleService articleService;

    @GetMapping
    public String list(Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        List<Category> categories = categoryService.findAll();
        model.addAttribute("categories", categories);
        return "admin/categories-list";
    }

    @GetMapping("/new")
    public String form(Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        model.addAttribute("category", new Category());
        return "admin/category-form";
    }

    @GetMapping("/form")
    public String categoryForm(Model model, HttpSession session, @RequestParam(required = false) Long id) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";

        Category category = new Category();
        
        // If id is provided, load existing category for editing
        if (id != null) {
            Optional<Category> existingCategory = categoryService.findById(id);
            if (existingCategory.isPresent()) {
                category = existingCategory.get();
            }
        }

        model.addAttribute("category", category);
        return "admin/category-form";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        Optional<Category> category = categoryService.findById(id);
        if (category.isPresent()) {
            model.addAttribute("category", category.get());
            return "admin/category-form";
        }
        return "redirect:/admin/categories";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        Optional<Category> category = categoryService.findById(id);
        if (category.isPresent()) {
            model.addAttribute("category", category.get());
            List<Article> articles = articleService.findByCategory(category.get());
            model.addAttribute("articles", articles);
            return "admin/category-detail";
        }
        return "redirect:/admin/categories";
    }

    @PostMapping("/form")
    public String saveForm(@ModelAttribute Category category, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        try {
            if (category.getId() != null && category.getId() > 0) {
                // Update existing category
                categoryService.updateCategory(category, user.getLogin());
            } else {
                // Create new category
                categoryService.createCategory(category, user.getLogin());
            }
            return "redirect:/admin/categories?success=1";
        } catch (Exception e) {
            return "redirect:/admin/categories/form?error=" + e.getMessage();
        }
    }

    @PostMapping
    public String create(@ModelAttribute Category category, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        try {
            categoryService.createCategory(category, user.getLogin());
            return "redirect:/admin/categories?success=1";
        } catch (Exception e) {
            return "redirect:/admin/categories?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}")
    public String update(@PathVariable Long id, @ModelAttribute Category category, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        try {
            category.setId(id);
            categoryService.updateCategory(category, user.getLogin());
            return "redirect:/admin/categories?success=1";
        } catch (Exception e) {
            return "redirect:/admin/categories?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        try {
            categoryService.deleteCategory(id, user.getLogin());
            return "redirect:/admin/categories?success=Categorie+supprimee";
        } catch (Exception e) {
            return "redirect:/admin/categories?error=" + e.getMessage();
        }
    }

    // ===== REST API =====
    
    @GetMapping("/api")
    @ResponseBody
    public ResponseEntity<List<CategoryDTO>> listApi() {
        List<CategoryDTO> dtos = categoryService.findAll().stream()
            .map(c -> CategoryDTO.builder()
                .id(c.getId())
                .code(c.getCode())
                .libelle(c.getLibelle())
                .description(c.getDescription())
                .actif(c.getActif())
                .utilisateurCreation(c.getUtilisateurCreation())
                .build())
            .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<CategoryDTO> getApi(@PathVariable Long id) {
        Optional<Category> category = categoryService.findById(id);
        if (category.isPresent()) {
            Category c = category.get();
            return ResponseEntity.ok(CategoryDTO.builder()
                .id(c.getId())
                .code(c.getCode())
                .libelle(c.getLibelle())
                .description(c.getDescription())
                .actif(c.getActif())
                .utilisateurCreation(c.getUtilisateurCreation())
                .build());
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createApi(@RequestBody Category category, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        try {
            Category saved = categoryService.createCategory(category, user.getLogin());
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("id", saved.getId());
            response.put("message", "Category created successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PutMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateApi(@PathVariable Long id, @RequestBody Category category, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        try {
            category.setId(id);
            categoryService.updateCategory(category, user.getLogin());
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Category updated successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @DeleteMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteApi(@PathVariable Long id, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        try {
            categoryService.deleteCategory(id, user.getLogin());
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Category deleted successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}
