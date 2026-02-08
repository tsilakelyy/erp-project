<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recherche globale - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="search"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero" style="grid-template-columns: 1fr;">
            <div>
                <h1>Recherche globale</h1>
                <p>Resultats pour: <strong><c:out value="${query}"/></strong></p>
            </div>
        </section>

        <c:if test="${empty query}">
            <section class="client-section">
                <div class="client-action-card">
                    Entrez un mot-cle pour rechercher vos produits, commandes, livraisons, factures, paiements et demandes.
                </div>
            </section>
        </c:if>

        <section class="client-section">
            <h2>Produits (${fn:length(articles)})</h2>
            <div class="client-products-grid">
                <c:forEach items="${articles}" var="article">
                    <div class="product-card">
                        <div class="product-card-header">
                            <span class="client-badge">Code: <c:out value="${article.code}"/></span>
                            <span><c:out value="${article.uniteMesure}"/></span>
                        </div>
                        <h3><c:out value="${article.libelle}"/></h3>
                        <div class="product-description">
                            <c:choose>
                                <c:when test="${not empty article.description}">
                                    <c:out value="${article.description}"/>
                                </c:when>
                                <c:otherwise>Description a completer.</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="product-price">Ar <c:out value="${article.prixUnitaire}"/></div>
                        <div class="product-actions">
                            <a class="client-link" href="<c:url value='/client/orders/new'/>">Commander</a>
                            <a class="client-link" href="<c:url value='/client/requests/new?type=DEVIS&articleId=${article.id}'/>">Devis</a>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty articles}">
                    <div class="client-action-card">Aucun produit correspondant.</div>
                </c:if>
            </div>
        </section>

        <section class="client-section">
            <h2>Commandes (${fn:length(orders)})</h2>
            <table class="client-table no-smart">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Montant TTC</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${orders}" var="order">
                        <tr>
                            <td><c:out value="${order.numero}"/></td>
                            <td><span class="client-pill"><c:out value="${order.statut}"/></span></td>
                            <td><c:out value="${order.dateCommande}"/></td>
                            <td>Ar <c:out value="${order.montantTtc}"/></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty orders}">
                        <tr><td colspan="4">Aucune commande correspondante.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <section class="client-section">
            <h2>Proformas (${fn:length(proformas)})</h2>
            <table class="client-table no-smart">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Montant TTC</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${proformas}" var="pf">
                        <tr>
                            <td><c:out value="${pf.numero}"/></td>
                            <td><span class="client-pill"><c:out value="${pf.statut}"/></span></td>
                            <td><c:out value="${pf.dateProforma}"/></td>
                            <td>Ar <c:out value="${pf.montantTtc}"/></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty proformas}">
                        <tr><td colspan="4">Aucune proforma correspondante.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <section class="client-section">
            <h2>Livraisons (${fn:length(deliveries)})</h2>
            <table class="client-table no-smart">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Date livraison</th>
                        <th>Commande</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${deliveries}" var="delivery">
                        <tr>
                            <td><c:out value="${delivery.numero}"/></td>
                            <td><span class="client-pill"><c:out value="${delivery.statut}"/></span></td>
                            <td><c:out value="${delivery.dateLivraison}"/></td>
                            <td><c:out value="${delivery.commandeClientId}"/></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty deliveries}">
                        <tr><td colspan="4">Aucune livraison correspondante.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <section class="client-section">
            <h2>Factures (${fn:length(invoices)})</h2>
            <table class="client-table no-smart">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Date facture</th>
                        <th>Montant</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${invoices}" var="inv">
                        <tr>
                            <td><c:out value="${inv.numero}"/></td>
                            <td><span class="client-pill"><c:out value="${inv.statut}"/></span></td>
                            <td><c:out value="${inv.dateFacture}"/></td>
                            <td>Ar <c:out value="${inv.montantTtc}"/></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty invoices}">
                        <tr><td colspan="4">Aucune facture correspondante.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <section class="client-section">
            <h2>Paiements (${fn:length(payments)})</h2>
            <table class="client-table no-smart">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Montant</th>
                        <th>Facture</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${payments}" var="payment">
                        <tr>
                            <td><c:out value="${payment.numero}"/></td>
                            <td><span class="client-pill"><c:out value="${payment.statut}"/></span></td>
                            <td>Ar <c:out value="${payment.montant}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${invoicesById[payment.factureId] != null}">
                                        <c:out value="${invoicesById[payment.factureId].numero}"/>
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty payments}">
                        <tr><td colspan="4">Aucun paiement correspondant.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <section class="client-section">
            <h2>Demandes (${fn:length(requests)})</h2>
            <table class="client-table no-smart">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>Titre</th>
                        <th>Statut</th>
                        <th>Montant</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${requests}" var="req">
                        <tr>
                            <td><c:out value="${req.requestType}"/></td>
                            <td><c:out value="${req.titre}"/></td>
                            <td><span class="client-pill"><c:out value="${req.statut}"/></span></td>
                            <td>Ar <c:out value="${req.montantEstime}"/></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty requests}">
                        <tr><td colspan="4">Aucune demande correspondante.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <div class="client-footer">Recherche globale connectee au back office.</div>
    </main>
</body>
</html>
