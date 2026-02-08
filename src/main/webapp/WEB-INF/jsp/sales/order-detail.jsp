<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail commande vente - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Commande ${order.numero}</h1>
                <a href="<c:url value='/sales/orders'/>" class="btn btn-secondary">Retour</a>
            </div>

            <div class="detail-container">
                <div class="detail-row">
                    <span class="detail-label">Statut :</span>
                    <span class="detail-value">${order.statut}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date :</span>
                    <span class="detail-value">${order.dateCommande}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Total :</span>
                    <span class="detail-value">Ar ${order.montantTtc}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Client ID :</span>
                    <span class="detail-value">${order.clientId}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Proforma :</span>
                    <span class="detail-value">${order.proformaId}</span>
                </div>
            </div>

            <div class="form-actions">
                <c:if test="${order.statut == 'BROUILLON' || order.statut == 'DEVIS' || order.statut == 'EN_COURS'}">
                    <form method="POST" action="<c:url value='/sales/orders/${order.id}/approve'/>" style="display:inline;">
                        <button type="submit" class="btn btn-primary">Valider la commande</button>
                    </form>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>
