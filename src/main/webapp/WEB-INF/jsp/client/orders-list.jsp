<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes commandes - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="orders"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero" style="grid-template-columns: 1fr;">
            <div>
                <h1>Mes commandes</h1>
                <p>Suivez l'avancement de vos commandes et preparez vos prochaines receptions.</p>
            </div>
        </section>

        <section class="client-section">
            <div class="client-section-header">
                <h2>Actions commandes</h2>
                <div class="client-section-actions">
                    <a class="client-link" href="<c:url value='/client/products'/>">Catalogue</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=DEVIS'/>">Devis</a>
                </div>
            </div>
            <div class="client-actions">
                <a class="client-action-card" href="<c:url value='/client/orders/new'/>">
                    Nouvelle commande
                    <span>Demander une commande et suivre sa validation</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/requests/new?type=LIVRAISON'/>">
                    Demander une livraison
                    <span>Planifier les receptions associees a vos commandes</span>
                </a>
            </div>
            <c:if test="${param.success == '1'}">
                <div class="client-action-card" style="margin-top: 12px;">
                    Commande enregistree avec succes.
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="client-action-card" style="margin-top: 12px;">
                    <c:out value="${param.error}"/>
                </div>
            </c:if>
        </section>

        <section class="client-section">
            <h2>Historique recent</h2>
            <table class="client-table">
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
                        <c:set var="pillClass" value="client-pill" />
                        <c:if test="${order.statut == 'LIVREE' || order.statut == 'VALIDEE'}">
                            <c:set var="pillClass" value="client-pill success" />
                        </c:if>
                        <tr>
                            <td><c:out value="${order.numero}"/></td>
                            <td><span class="${pillClass}"><c:out value="${order.statut}"/></span></td>
                            <td><c:out value="${order.dateCommande}"/></td>
                            <td>Ar <c:out value="${order.montantTtc}"/></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty orders}">
                        <tr>
                            <td colspan="4">Aucune commande enregistree.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <div class="client-footer">Besoin d'aide ? Contactez votre charge de compte.</div>
    </main>
</body>
</html>
