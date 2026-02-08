<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Entrepot - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Entrepot ${wh.nomDepot}</h1>
                <a href="<c:url value='/warehouses'/>" class="btn btn-secondary">Retour</a>
            </div>

            <div class="detail-container">
                <div class="detail-item"><strong>Code :</strong> ${wh.code}</div>
                <div class="detail-item"><strong>Nom :</strong> ${wh.nomDepot}</div>
                <div class="detail-item"><strong>Type :</strong> <c:out value="${wh.typeDepot}" default="-" /></div>
                <div class="detail-item"><strong>Adresse :</strong> <c:out value="${wh.adresse}" default="-" /></div>
                <div class="detail-item"><strong>Code postal :</strong> <c:out value="${wh.codePostal}" default="-" /></div>
                <div class="detail-item"><strong>Ville :</strong> <c:out value="${wh.ville}" default="-" /></div>
                <div class="detail-item"><strong>Capacite max :</strong> <c:out value="${wh.capaciteMaximale}" default="-" /></div>
                <div class="detail-item"><strong>Statut :</strong> <span class="badge ${wh.actif ? 'badge-success' : 'badge-secondary'}">${wh.actif ? 'Actif' : 'Inactif'}</span></div>
            </div>
        </div>
    </div>
</body>
</html>
