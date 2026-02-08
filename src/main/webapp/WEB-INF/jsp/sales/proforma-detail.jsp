<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail proforma client - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Proforma ${proforma.numero}</h1>
                <a href="<c:url value='/sales/proformas'/>" class="btn btn-secondary">Retour</a>
            </div>

            <div class="detail-container">
                <div class="detail-row">
                    <span class="detail-label">Client :</span>
                    <span class="detail-value">
                        <c:choose>
                            <c:when test="${not empty customer}"><c:out value="${customer.nomEntreprise}"/></c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Statut :</span>
                    <span class="detail-value">${proforma.statut}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date :</span>
                    <span class="detail-value">${proforma.dateProforma}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Montant HT :</span>
                    <span class="detail-value">Ar ${proforma.montantHt}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">TVA :</span>
                    <span class="detail-value">Ar ${proforma.montantTva}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Total TTC :</span>
                    <span class="detail-value">Ar ${proforma.montantTtc}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Entrepot :</span>
                    <span class="detail-value">
                        <c:choose>
                            <c:when test="${not empty warehouse}"><c:out value="${warehouse.nomDepot}"/></c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>

            <div class="form-actions">
                <c:if test="${proforma.statut == 'EN_ATTENTE'}">
                    <form method="POST" action="<c:url value='/sales/proformas/${proforma.id}/validate'/>" style="display:inline;">
                        <button type="submit" class="btn btn-success">Valider par le client</button>
                    </form>
                    <form method="POST" action="<c:url value='/sales/proformas/${proforma.id}/reject'/>" style="display:inline;">
                        <button type="submit" class="btn btn-danger">Rejeter</button>
                    </form>
                </c:if>
                <c:if test="${proforma.statut == 'VALIDEE_CLIENT'}">
                    <form method="POST" action="<c:url value='/sales/proformas/${proforma.id}/to-order'/>" style="display:inline;">
                        <button type="submit" class="btn btn-primary">Transformer en commande</button>
                    </form>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>
