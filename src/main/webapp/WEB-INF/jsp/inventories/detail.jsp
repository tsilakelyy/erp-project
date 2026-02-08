<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail inventaire - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>
                    Inventaire
                    <c:out value="${inventory.numero}" default="-" />
                </h1>
                <a href="<c:url value='/inventories'/>" class="btn btn-secondary">Retour</a>
            </div>

            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" id="formError" data-error="<c:out value='${param.error}'/>"></div>
                <script>
                    (function() {
                        var el = document.getElementById('formError');
                        if (!el) return;
                        var raw = el.getAttribute('data-error') || '';
                        try {
                            el.textContent = decodeURIComponent(raw.replace(/\\+/g, ' '));
                        } catch (e) {
                            el.textContent = raw;
                        }
                    })();
                </script>
            </c:if>

            <div class="detail-container">
                <div class="detail-row">
                    <span class="detail-label">Type :</span>
                    <span class="detail-value"><c:out value="${inventory.typeInventaire}" default="-" /></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Entrepot (ID) :</span>
                    <span class="detail-value"><c:out value="${inventory.entrepotId}" default="-" /></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Statut :</span>
                    <span class="detail-value"><span class="badge badge-info"><c:out value="${inventory.statut}" default="-" /></span></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date debut :</span>
                    <span class="detail-value"><c:out value="${inventory.dateDebut}" default="-" /></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date fin :</span>
                    <span class="detail-value"><c:out value="${inventory.dateFin}" default="-" /></span>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
