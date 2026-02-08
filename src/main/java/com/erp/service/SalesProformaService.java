package com.erp.service;

import com.erp.domain.Article;
import com.erp.domain.ClientRequest;
import com.erp.domain.Customer;
import com.erp.domain.SalesProforma;
import com.erp.domain.SalesProformaLine;
import com.erp.repository.ArticleRepository;
import com.erp.repository.ClientRequestRepository;
import com.erp.repository.CustomerRepository;
import com.erp.repository.SalesProformaRepository;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class SalesProformaService {

    @Autowired
    private SalesProformaRepository salesProformaRepository;

    @Autowired
    private ClientRequestRepository clientRequestRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private ArticleRepository articleRepository;

    @Autowired
    private WarehouseRepository warehouseRepository;
    @Autowired
    private AuditService auditService;

    public List<SalesProforma> findAll() {
        return salesProformaRepository.findAll();
    }

    public Optional<SalesProforma> get(Long id) {
        return salesProformaRepository.findById(id);
    }

    public SalesProforma create(SalesProforma proforma, String currentUsername) {
        if (proforma.getNumero() == null || proforma.getNumero().trim().isEmpty()) {
            proforma.setNumero(generateNumero("PFV"));
        }
        if (proforma.getStatut() == null || proforma.getStatut().trim().isEmpty()) {
            proforma.setStatut("EN_ATTENTE");
        }

        LocalDateTime now = LocalDateTime.now();
        if (proforma.getDateCreation() == null) proforma.setDateCreation(now);
        if (proforma.getDateProforma() == null) proforma.setDateProforma(now);
        proforma.setUtilisateurCreation(currentUsername);
        proforma.setUtilisateurModification(currentUsername);

        if (proforma.getRequestId() != null) {
            clientRequestRepository.findById(proforma.getRequestId()).ifPresent(req -> {
                String type = req.getRequestType() != null ? req.getRequestType().trim().toUpperCase() : "";
                if (!type.isEmpty()
                    && !"DEVIS".equals(type)
                    && !"COMMANDE".equals(type)
                    && !"ORDER_REQUEST".equals(type)) {
                    throw new IllegalArgumentException("Type de demande incompatible avec une proforma: " + type);
                }
                if (proforma.getClientId() == null) {
                    proforma.setClientId(req.getCustomerId());
                }
                if (proforma.getMontantHt() == null && req.getMontantEstime() != null) {
                    proforma.setMontantHt(req.getMontantEstime());
                }
                if (req.getArticleId() != null && (proforma.getLines() == null || proforma.getLines().isEmpty())) {
                    articleRepository.findById(req.getArticleId()).ifPresent(article -> {
                        SalesProformaLine line = new SalesProformaLine();
                        line.setProforma(proforma);
                        line.setArticle(article);
                        int qty = req.getQuantite() != null ? req.getQuantite().intValue() : 1;
                        if (qty <= 0) qty = 1;
                        line.setQuantite(qty);
                        line.setPrixUnitaire(article.getPrixUnitaire());
                        if (article.getPrixUnitaire() != null) {
                            line.setMontant(article.getPrixUnitaire().multiply(BigDecimal.valueOf(qty)));
                        }
                        proforma.getLines().add(line);
                        if (proforma.getTauxTva() == null && article.getTauxTva() != null) {
                            proforma.setTauxTva(article.getTauxTva());
                        }
                    });
                }
            });
        }

        if (proforma.getClientId() == null) {
            throw new IllegalArgumentException("Client requis pour la proforma");
        }
        ensureClientExists(proforma.getClientId());

        if (proforma.getEntrepotId() == null) {
            warehouseRepository.findAll().stream().findFirst().ifPresent(w -> proforma.setEntrepotId(w.getId()));
        }

        calculateTotals(proforma);

        SalesProforma saved = salesProformaRepository.save(proforma);
        auditService.logAction("SalesProforma", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public SalesProforma validateByClient(Long id, String currentUsername) {
        SalesProforma proforma = salesProformaRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Proforma introuvable"));

        if (!"EN_ATTENTE".equalsIgnoreCase(proforma.getStatut())) {
            throw new IllegalArgumentException("La proforma doit etre en attente pour etre validee");
        }
        proforma.setStatut("VALIDEE_CLIENT");
        proforma.setDateValidationClient(LocalDateTime.now());
        proforma.setUtilisateurModification(currentUsername);
        SalesProforma updated = salesProformaRepository.save(proforma);
        auditService.logAction("SalesProforma", updated.getId(), "VALIDATE_CLIENT", currentUsername);

        if (proforma.getRequestId() != null) {
            clientRequestRepository.findById(proforma.getRequestId()).ifPresent(req -> {
                req.setStatut("VALIDEE");
                req.setDateModification(LocalDateTime.now());
                clientRequestRepository.save(req);
            });
        }
        return updated;
    }

    public SalesProforma reject(Long id, String currentUsername) {
        SalesProforma proforma = salesProformaRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Proforma introuvable"));

        proforma.setStatut("REJETEE");
        proforma.setUtilisateurModification(currentUsername);
        SalesProforma updated = salesProformaRepository.save(proforma);
        auditService.logAction("SalesProforma", updated.getId(), "REJECT", currentUsername);
        return updated;
    }

    public List<SalesProforma> findByClient(Long clientId) {
        return salesProformaRepository.findByClientId(clientId);
    }

    private void calculateTotals(SalesProforma proforma) {
        BigDecimal totalHt = BigDecimal.ZERO;

        if (proforma.getLines() != null && !proforma.getLines().isEmpty()) {
            for (SalesProformaLine line : proforma.getLines()) {
                if (line.getArticle() == null && line.getMontant() == null) continue;
                BigDecimal lineTotal = line.getMontant();
                if (lineTotal == null && line.getPrixUnitaire() != null && line.getQuantite() != null) {
                    lineTotal = line.getPrixUnitaire().multiply(BigDecimal.valueOf(line.getQuantite()));
                    line.setMontant(lineTotal);
                }
                if (lineTotal != null) {
                    totalHt = totalHt.add(lineTotal);
                }
            }
        } else if (proforma.getMontantHt() != null) {
            totalHt = proforma.getMontantHt();
        }

        BigDecimal tauxTva = proforma.getTauxTva() != null ? proforma.getTauxTva() : BigDecimal.ZERO;
        BigDecimal tva = totalHt.multiply(tauxTva).divide(BigDecimal.valueOf(100));
        proforma.setMontantHt(totalHt);
        proforma.setMontantTva(tva);
        proforma.setMontantTtc(totalHt.add(tva));
    }

    private void ensureClientExists(Long clientId) {
        Optional<Customer> customer = customerRepository.findById(clientId);
        if (customer.isEmpty()) {
            throw new IllegalArgumentException("Client introuvable");
        }
    }

    private String generateNumero(String prefix) {
        String base = prefix + "-" + LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String numero = base;
        int suffix = 1;
        while (salesProformaRepository.findByNumero(numero).isPresent()) {
            numero = base + "-" + suffix;
            suffix++;
        }
        return numero;
    }
}
