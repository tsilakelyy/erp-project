<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail facture - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Facture ${invoice.numero}</h1>
                <a href="<c:url value='/sales/invoices'/>" class="btn btn-secondary">Retour</a>
                <a href="<c:url value='/invoices/${invoice.id}/pdf'/>" class="btn btn-primary">Exporter PDF</a>
            </div>

            <div class="detail-container">
                <div class="detail-row">
                    <span class="detail-label">Statut :</span>
                    <span class="detail-value">${invoice.statut}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Type :</span>
                    <span class="detail-value">${invoice.typeFacture}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date facture :</span>
                    <span class="detail-value">${invoice.dateFacture}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Echeance :</span>
                    <span class="detail-value">${invoice.dateEcheance}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Tiers ID :</span>
                    <span class="detail-value">${invoice.tiersId}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Type tiers :</span>
                    <span class="detail-value">${invoice.typeTiers}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Commande client :</span>
                    <span class="detail-value">${invoice.commandeClientId}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Montant HT :</span>
                    <span class="detail-value">Ar ${invoice.montantHt}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">TVA :</span>
                    <span class="detail-value">Ar ${invoice.montantTva}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Total TTC :</span>
                    <span class="detail-value">Ar ${invoice.montantTtc}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Taux TVA :</span>
                    <span class="detail-value">${invoice.tauxTva}</span>
                </div>
            </div>

            <c:if test="${invoice.statut != 'PAYEE'}">
                <div class="detail-container" style="margin-top: 20px;">
                    <h3>Encaissement</h3>
                    <form method="POST" action="<c:url value='/sales/invoices/${invoice.id}/pay'/>">
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Moyen de paiement</label>
                                <select name="moyenPaiement" class="form-select">
                                    <option value="VIREMENT">Virement</option>
                                    <option value="CHEQUE">Cheque</option>
                                    <option value="ESPECES">Especes</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Reference</label>
                                <input type="text" name="reference" class="form-control" placeholder="Reference transaction">
                            </div>
                            <div class="form-group">
                                <label>Montant (Ar)</label>
                                <input type="number" name="montant" class="form-control" step="0.01" value="${invoice.montantTtc}">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">Enregistrer paiement</button>
                    </form>
                </div>
            </c:if>
        </div>
    </div>
</body>
</html>
