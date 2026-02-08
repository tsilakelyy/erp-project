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
                <h1 id="pageTitle">Nouvel entrepot</h1>
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

            <form id="warehouseForm" method="POST" action="<c:url value='/warehouses/form'/>">
                <input type="hidden" id="warehouseId" name="id">

                <div class="form-row">
                    <div class="form-group">
                        <label for="code">Code *</label>
                        <input type="text" id="code" name="code" class="form-control" required maxlength="50">
                    </div>
                    <div class="form-group">
                        <label for="nomDepot">Nom *</label>
                        <input type="text" id="nomDepot" name="nomDepot" class="form-control" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="adresse">Adresse</label>
                    <input type="text" id="adresse" name="adresse" class="form-control">
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="typeDepot">Type *</label>
                        <select id="typeDepot" name="typeDepot" class="form-control" required>
                            <option value="">-- Selectionner --</option>
                            <option value="PRINCIPAL">Principal</option>
                            <option value="SECONDAIRE">Secondaire</option>
                            <option value="TRANSIT">Transit</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="capaciteMaximale">Capacite max *</label>
                        <input type="number" step="0.01" id="capaciteMaximale" name="capaciteMaximale" class="form-control" required>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Enregistrer</button>
                    <a href="<c:url value='/warehouses'/>" class="btn btn-secondary">Annuler</a>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const whId = new URLSearchParams(window.location.search).get('id');
            if (whId) loadWarehouse(whId);
        });

        function loadWarehouse(id) {
            ajaxCall(APP_CONTEXT + '/api/warehouses/' + id, 'GET', null,
                function(wh) {
                    document.getElementById('pageTitle').textContent = 'Modifier un entrepot';
                    document.getElementById('warehouseId').value = wh.id;
                    document.getElementById('code').value = wh.code;
                    document.getElementById('nomDepot').value = wh.nomDepot;
                    document.getElementById('adresse').value = wh.adresse || '';
                    document.getElementById('typeDepot').value = wh.typeDepot;
                    document.getElementById('capaciteMaximale').value = wh.capaciteMaximale;
                },
                function() { showError('Chargement impossible'); }
            );
        }

    </script>
</body>
</html>


