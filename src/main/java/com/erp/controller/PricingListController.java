package com.erp.controller;

import com.erp.domain.PricingList;
import com.erp.domain.PricingListLine;
import com.erp.domain.Article;
import com.erp.domain.User;
import com.erp.dto.PricingListDTO;
import com.erp.dto.PricingListLineDTO;
import com.erp.service.PricingListService;
import com.erp.service.ArticleService;
import com.erp.repository.ArticleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin/pricing-lists")
public class PricingListController {

    @Autowired
    private PricingListService pricingListService;

    @Autowired
    private ArticleRepository articleRepository;

    @GetMapping
    @Transactional(readOnly = true)
    public String list(@RequestParam(required = false) String type, Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        List<PricingList> pricingLists;
        if (type != null && !type.isEmpty()) {
            pricingLists = pricingListService.findByType(type);
        } else {
            pricingLists = pricingListService.findAll();
        }
        
        // Force initialization of lazy-loaded collections
        for (PricingList pl : pricingLists) {
            if (pl.getLines() != null) {
                pl.getLines().size(); // Trigger lazy loading
            }
        }
        
        model.addAttribute("pricingLists", pricingLists);
        model.addAttribute("types", new String[]{"VENTE", "ACHAT", "GENERAL"});
        model.addAttribute("selectedType", type);
        return "admin/pricing-lists";
    }

    @GetMapping("/new")
    public String form(Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        model.addAttribute("pricingList", new PricingList());
        model.addAttribute("types", new String[]{"VENTE", "ACHAT", "GENERAL"});
        return "admin/pricing-list-form";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        Optional<PricingList> pricingList = pricingListService.findById(id);
        if (pricingList.isPresent()) {
            PricingList pl = pricingList.get();
            List<Article> articles = articleRepository.findAll();
            model.addAttribute("pricingList", pl);
            model.addAttribute("lines", pl.getLines());
            model.addAttribute("articles", articles);
            return "admin/pricing-list-detail";
        }
        return "redirect:/admin/pricing-lists";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        Optional<PricingList> pricingList = pricingListService.findById(id);
        if (pricingList.isPresent()) {
            model.addAttribute("pricingList", pricingList.get());
            model.addAttribute("types", new String[]{"VENTE", "ACHAT", "GENERAL"});
            return "admin/pricing-list-form";
        }
        return "redirect:/admin/pricing-lists";
    }

    @PostMapping
    public String create(@ModelAttribute PricingList pricingList, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        try {
            PricingList saved = pricingListService.createPricingList(pricingList, user.getLogin());
            return "redirect:/admin/pricing-lists/" + saved.getId() + "?success=1";
        } catch (Exception e) {
            return "redirect:/admin/pricing-lists?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}")
    public String update(@PathVariable Long id, @ModelAttribute PricingList pricingList, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        try {
            pricingList.setId(id);
            pricingListService.updatePricingList(pricingList, user.getLogin());
            return "redirect:/admin/pricing-lists/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/admin/pricing-lists?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";
        
        try {
            pricingListService.deletePricingList(id, user.getLogin());
            return "redirect:/admin/pricing-lists?success=Liste+supprimee";
        } catch (Exception e) {
            return "redirect:/admin/pricing-lists?error=" + e.getMessage();
        }
    }

    // ===== REST API =====
    
    @GetMapping("/api")
    @ResponseBody
    public ResponseEntity<List<PricingListDTO>> listApi(@RequestParam(required = false) String type) {
        List<PricingList> lists;
        if (type != null && !type.isEmpty()) {
            lists = pricingListService.findByType(type);
        } else {
            lists = pricingListService.findAll();
        }
        
        List<PricingListDTO> dtos = lists.stream()
            .map(pl -> PricingListDTO.builder()
                .id(pl.getId())
                .code(pl.getCode())
                .libelle(pl.getLibelle())
                .description(pl.getDescription())
                .typeListe(pl.getTypeListe())
                .dateDebut(pl.getDateDebut())
                .dateFin(pl.getDateFin())
                .devise(pl.getDevise())
                .actif(pl.getActif())
                .parDefaut(pl.getParDefaut())
                .lineCount(pl.getLines() != null ? pl.getLines().size() : 0)
                .build())
            .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<PricingListDTO> getApi(@PathVariable Long id) {
        Optional<PricingList> pricingList = pricingListService.findById(id);
        if (pricingList.isPresent()) {
            PricingList pl = pricingList.get();
            return ResponseEntity.ok(PricingListDTO.builder()
                .id(pl.getId())
                .code(pl.getCode())
                .libelle(pl.getLibelle())
                .description(pl.getDescription())
                .typeListe(pl.getTypeListe())
                .dateDebut(pl.getDateDebut())
                .dateFin(pl.getDateFin())
                .devise(pl.getDevise())
                .actif(pl.getActif())
                .parDefaut(pl.getParDefaut())
                .lineCount(pl.getLines() != null ? pl.getLines().size() : 0)
                .build());
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/api/{id}/lines")
    @ResponseBody
    public ResponseEntity<List<PricingListLineDTO>> getLinesApi(@PathVariable Long id) {
        List<PricingListLine> lines = pricingListService.getLines(id);
        List<PricingListLineDTO> dtos = lines.stream()
            .map(line -> PricingListLineDTO.builder()
                .id(line.getId())
                .pricingListId(line.getPricingList().getId())
                .articleId(line.getArticle().getId())
                .articleCode(line.getArticle().getCode())
                .articleLibelle(line.getArticle().getLibelle())
                .prixUnitaire(line.getPrixUnitaire())
                .remisePourcentage(line.getRemisePourcentage())
                .prixNet(line.getPrixNet())
                .remarque(line.getRemarque())
                .actif(line.getActif())
                .build())
            .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createApi(@RequestBody PricingList pricingList, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        try {
            PricingList saved = pricingListService.createPricingList(pricingList, user.getLogin());
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("id", saved.getId());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PostMapping("/api/{id}/lines")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addLineApi(@PathVariable Long id, @RequestBody PricingListLine line, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        try {
            if (line.getArticle() == null || line.getArticle().getId() == null) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("error", "Article ID is required");
                return ResponseEntity.badRequest().body(response);
            }
            PricingListLine saved = pricingListService.addLineItem(id, line.getArticle().getId(), line, user.getLogin());
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("lineId", saved.getId());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PutMapping("/api/{id}/lines/{lineId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateLineApi(@PathVariable Long lineId, @RequestBody PricingListLine lineData, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        try {
            pricingListService.updateLineItem(lineId, lineData, user.getLogin());
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @DeleteMapping("/api/{id}/lines/{lineId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteLineApi(@PathVariable Long lineId, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        try {
            pricingListService.deleteLine(lineId, user.getLogin());
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}
