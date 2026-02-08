package com.erp.controller;

import com.erp.domain.Proforma;
import com.erp.domain.Supplier;
import com.erp.domain.User;
import com.erp.repository.WarehouseRepository;
import com.erp.service.ProformaService;
import com.erp.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/purchases/proformas")
public class ProformaController {

    @Autowired
    private ProformaService proformaService;

    @Autowired
    private SupplierService supplierService;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @GetMapping
    public String list(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";

        List<Proforma> proformas = proformaService.findAll();
        proformas.sort(Comparator
            .comparing((Proforma p) -> p.getMontantTtc() != null ? p.getMontantTtc() : BigDecimal.ZERO)
            .thenComparing(Proforma::getDateCreation, Comparator.nullsLast(Comparator.reverseOrder())));
        model.addAttribute("proformas", proformas);

        Map<Long, String> supplierNames = new HashMap<>();
        for (Supplier s : supplierService.findAll()) {
            supplierNames.put(s.getId(), s.getNomEntreprise());
        }
        model.addAttribute("supplierNames", supplierNames);

        return "purchases/proformas-list";
    }

    @GetMapping("/new")
    public String form(Model model, Authentication auth, HttpSession session,
                       @RequestParam(required = false) Long requestId) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";

        Proforma proforma = new Proforma();
        proforma.setDemandeId(requestId);
        model.addAttribute("proforma", proforma);
        model.addAttribute("suppliers", supplierService.findAllActive());
        model.addAttribute("warehouses", warehouseRepository.findAll());
        return "purchases/proforma-form";
    }

    @PostMapping
    public String create(@ModelAttribute Proforma proforma, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        try {
            Proforma saved = proformaService.create(proforma, username);
            return "redirect:/purchases/proformas?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/proformas/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";

        Optional<Proforma> proforma = proformaService.get(id);
        if (proforma.isEmpty()) return "redirect:/purchases/proformas?error=Proforma+introuvable";

        model.addAttribute("proforma", proforma.get());
        supplierService.findById(proforma.get().getFournisseurId())
            .ifPresent(s -> model.addAttribute("supplier", s));

        warehouseRepository.findById(proforma.get().getEntrepotId())
            .ifPresent(w -> model.addAttribute("warehouse", w));

        User sessionUser = (User) session.getAttribute("user");
        boolean isAdmin = hasRole(sessionUser, "ADMIN");
        model.addAttribute("isFinance", hasRole(sessionUser, "FINANCE") || isAdmin);
        model.addAttribute("isDirection", hasRole(sessionUser, "DIRECTION") || isAdmin);

        return "purchases/proforma-detail";
    }

    @PostMapping("/{id}/validate-finance")
    public String validateFinance(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        User sessionUser = (User) session.getAttribute("user");
        if (!hasRole(sessionUser, "FINANCE") && !hasRole(sessionUser, "ADMIN")) {
            return "redirect:/purchases/proformas/" + id + "?error=Validation+reservee+au+role+FINANCE";
        }

        try {
            proformaService.validateFinance(id, username);
            return "redirect:/purchases/proformas/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/proformas/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/{id}/validate-direction")
    public String validateDirection(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        User sessionUser = (User) session.getAttribute("user");
        if (!hasRole(sessionUser, "DIRECTION") && !hasRole(sessionUser, "ADMIN")) {
            return "redirect:/purchases/proformas/" + id + "?error=Validation+reservee+au+role+DIRECTION";
        }

        try {
            proformaService.validateDirection(id, username);
            return "redirect:/purchases/proformas/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/proformas/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/{id}/reject")
    public String reject(@PathVariable Long id,
                         @RequestParam(required = false) String motif,
                         Authentication auth,
                         HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        try {
            proformaService.reject(id, motif, username);
            return "redirect:/purchases/proformas/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/proformas/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/{id}/to-order")
    public String toOrder(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        try {
            Long orderId = proformaService.transformToPurchaseOrder(id, username).getId();
            return "redirect:/purchases/orders/" + orderId + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/proformas/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    private boolean hasRole(User user, String roleCode) {
        if (user == null || user.getRoles() == null || roleCode == null) return false;
        return user.getRoles().stream().anyMatch(r -> roleCode.equalsIgnoreCase(r.getCode()));
    }
}
