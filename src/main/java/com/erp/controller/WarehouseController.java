package com.erp.controller;

import com.erp.domain.Warehouse;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.Optional;

@Controller
@RequestMapping("/warehouses")
public class WarehouseController {

    @Autowired
    private WarehouseRepository warehouseRepository;

    @GetMapping
    public String list(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        model.addAttribute("warehouses", warehouseRepository.findAll());
        return "warehouses/list";
    }

    @GetMapping("/detail/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Warehouse> wh = warehouseRepository.findById(id);
        if (wh.isEmpty()) {
            return "redirect:/warehouses?error=Entrepot+introuvable";
        }
        model.addAttribute("wh", wh.get());
        return "warehouses/detail";
    }

    @GetMapping("/form")
    public String form(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        return "warehouses/form";
    }

    /**
     * Fallback server-side save for the Warehouse form.
     * The UI uses AJAX, but if JS fails we still want "Enregistrer" to work.
     */
    @PostMapping("/form")
    public String save(@ModelAttribute Warehouse warehouse, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }

        try {
            String code = warehouse.getCode() != null ? warehouse.getCode().trim() : "";
            String nomDepot = warehouse.getNomDepot() != null ? warehouse.getNomDepot().trim() : "";
            String typeDepot = warehouse.getTypeDepot() != null ? warehouse.getTypeDepot().trim() : "";

            if (code.isEmpty()) {
                return "redirect:/warehouses/form?error=" + ControllerHelper.urlEncode("Le code est obligatoire");
            }
            if (nomDepot.isEmpty()) {
                return "redirect:/warehouses/form?error=" + ControllerHelper.urlEncode("Le nom est obligatoire");
            }
            if (typeDepot.isEmpty()) {
                return "redirect:/warehouses/form?error=" + ControllerHelper.urlEncode("Le type est obligatoire");
            }
            if (warehouse.getCapaciteMaximale() == null) {
                return "redirect:/warehouses/form?error=" + ControllerHelper.urlEncode("La capacite maximale est obligatoire");
            }

            String normalizedCode = code.toUpperCase(Locale.ROOT);

            if (warehouse.getId() == null) {
                // Create
                if (warehouseRepository.findByCode(normalizedCode).isPresent()) {
                    return "redirect:/warehouses/form?error=" + ControllerHelper.urlEncode("Un entrepot avec ce code existe deja");
                }

                Warehouse wh = new Warehouse();
                wh.setCode(normalizedCode);
                wh.setNomDepot(nomDepot);
                wh.setAdresse(warehouse.getAdresse());
                wh.setTypeDepot(typeDepot);
                wh.setCapaciteMaximale(warehouse.getCapaciteMaximale());
                wh.setActif(true);
                wh.setDateCreation(LocalDateTime.now());
                wh.setDateModification(LocalDateTime.now());
                wh.setUtilisateurCreation(username);
                wh.setUtilisateurModification(username);

                warehouseRepository.save(wh);
                return "redirect:/warehouses?success=1";
            }

            // Update
            Optional<Warehouse> existingOpt = warehouseRepository.findById(warehouse.getId());
            if (existingOpt.isEmpty()) {
                return "redirect:/warehouses?error=" + ControllerHelper.urlEncode("Entrepot introuvable");
            }

            Warehouse existing = existingOpt.get();
            warehouseRepository.findByCode(normalizedCode)
                .filter(other -> !other.getId().equals(existing.getId()))
                .ifPresent(other -> { throw new DataIntegrityViolationException("DUPLICATE_CODE"); });

            existing.setCode(normalizedCode);
            existing.setNomDepot(nomDepot);
            existing.setAdresse(warehouse.getAdresse());
            existing.setTypeDepot(typeDepot);
            existing.setCapaciteMaximale(warehouse.getCapaciteMaximale());
            existing.setDateModification(LocalDateTime.now());
            existing.setUtilisateurModification(username);

            warehouseRepository.save(existing);
            return "redirect:/warehouses?success=1";

        } catch (Exception e) {
            if (e instanceof DataIntegrityViolationException && "DUPLICATE_CODE".equals(e.getMessage())) {
                return "redirect:/warehouses/form?error=" + ControllerHelper.urlEncode("Un entrepot avec ce code existe deja");
            }
            String msg = (e.getMessage() == null || e.getMessage().trim().isEmpty())
                ? "Erreur lors de l'enregistrement"
                : e.getMessage();
            return "redirect:/warehouses/form?error=" + ControllerHelper.urlEncode(msg);
        }
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }

        Optional<Warehouse> whOpt = warehouseRepository.findById(id);
        if (whOpt.isEmpty()) {
            return "redirect:/warehouses?error=" + ControllerHelper.urlEncode("Entrepot introuvable");
        }

        Warehouse wh = whOpt.get();
        wh.setActif(false);
        wh.setDateModification(LocalDateTime.now());
        wh.setUtilisateurModification(username);
        warehouseRepository.save(wh);
        return "redirect:/warehouses?success=1";
    }
}
