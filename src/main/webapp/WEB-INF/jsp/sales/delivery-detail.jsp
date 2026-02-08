<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail livraison - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Livraison ${delivery.numero}</h1>
                <a href="<c:url value='/sales/deliveries'/>" class="btn btn-secondary">Retour</a>
            </div>

            <div class="detail-container">
                <div class="detail-row">
                    <span class="detail-label">Statut :</span>
                    <span class="detail-value">${delivery.statut}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Creation :</span>
                    <span class="detail-value">${delivery.dateCreation}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date livraison :</span>
                    <span class="detail-value">${delivery.dateLivraison}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Commande ID :</span>
                    <span class="detail-value">${delivery.commandeClientId}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Entrepot ID :</span>
                    <span class="detail-value">${delivery.entrepotId}</span>
                </div>
            </div>

            <div class="form-actions">
                <c:if test="${delivery.statut == 'EN_PREPARATION'}">
                    <form method="POST" action="<c:url value='/sales/deliveries/${delivery.id}/ship'/>" style="display:inline;">
                        <button type="submit" class="btn btn-primary">Expedier</button>
                    </form>
                </c:if>
                <c:if test="${delivery.statut == 'EXPEDIEE'}">
                    <form method="POST" action="<c:url value='/sales/deliveries/${delivery.id}/receive'/>" style="display:inline;">
                        <button type="submit" class="btn btn-primary">Receptionner</button>
                    </form>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>
