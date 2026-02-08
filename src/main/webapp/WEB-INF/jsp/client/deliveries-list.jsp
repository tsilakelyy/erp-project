<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes livraisons - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="deliveries"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero" style="grid-template-columns: 1fr;">
            <div>
                <h1>Mes livraisons</h1>
                <p>Gardez la visibilite sur les expeditions et les receptions.</p>
            </div>
        </section>

        <section class="client-section">
            <div class="client-section-header">
                <h2>Livraisons en cours</h2>
                <div class="client-section-actions">
                    <a class="client-link" href="<c:url value='/client/requests/new?type=LIVRAISON'/>">Nouvelle livraison</a>
                    <a class="client-link" href="<c:url value='/client/orders'/>">Voir commandes</a>
                </div>
            </div>
            <table class="client-table">
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
                        <c:set var="pillClass" value="client-pill" />
                        <c:if test="${delivery.statut == 'EXPEDIEE' || delivery.statut == 'VALIDEE'}">
                            <c:set var="pillClass" value="client-pill success" />
                        </c:if>
                        <tr>
                            <td><c:out value="${delivery.numero}"/></td>
                            <td><span class="${pillClass}"><c:out value="${delivery.statut}"/></span></td>
                            <td><c:out value="${delivery.dateLivraison}"/></td>
                            <td><c:out value="${delivery.commandeClientId}"/></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty deliveries}">
                        <tr>
                            <td colspan="4">Aucune livraison pour le moment.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <div class="client-footer">Vous serez notifie lors de chaque expedition.</div>
    </main>
</body>
</html>
