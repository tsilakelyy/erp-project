<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nouvel inventaire - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Nouvel inventaire</h1>
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

            <form method="POST" action="<c:url value='/inventories'/>">
                <div class="form-group">
                    <label for="typeInventaire">Type d'inventaire *</label>
                    <select id="typeInventaire" name="typeInventaire" class="form-control" required>
                        <option value="">Selectionner</option>
                        <option value="TOURNANT">Tournant</option>
                        <option value="CYCLIQUE">Cyclique</option>
                        <option value="ANNUEL">Annuel</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="entrepotId">Entrepot *</label>
                    <select id="entrepotId" name="entrepotId" class="form-control" required>
                        <option value="">Selectionner</option>
                        <c:forEach items="${warehouses}" var="wh">
                            <option value="${wh.id}">
                                <c:out value="${wh.code}"/> - <c:out value="${wh.nomDepot}"/> (<c:out value="${wh.ville}"/>)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Creer</button>
                    <a href="<c:url value='/inventories'/>" class="btn btn-secondary">Annuler</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
