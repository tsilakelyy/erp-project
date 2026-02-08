<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catégorie - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1 id="pageTitle">Nouvelle Catégorie</h1>
                <a href="<c:url value='/admin/categories'/>" class="btn btn-secondary">Retour</a>
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

            <div class="form-card">
                <form id="categoryForm" method="POST" action="<c:url value='/admin/categories/form'/>">
                    <input type="hidden" id="categoryId" name="id">

                    <div class="form-group">
                        <label>Code *</label>
                        <input type="text" id="code" name="code" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label>Libellé *</label>
                        <input type="text" id="libelle" name="libelle" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label>Description</label>
                        <textarea id="description" name="description" class="form-control" rows="4"></textarea>
                    </div>

                    <div class="form-group">
                        <label>
                            <input type="hidden" name="actif" value="false">
                            <input type="checkbox" id="actif" name="actif" value="true"> Actif
                        </label>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Enregistrer</button>
                        <a href="<c:url value='/admin/categories'/>" class="btn btn-secondary">Annuler</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const catId = new URLSearchParams(window.location.search).get('id');
            if (catId) loadCategory(catId);
        });

        function loadCategory(id) {
            ajaxCall(APP_CONTEXT + '/admin/categories/api/' + id, 'GET', null,
                function(cat) {
                    document.getElementById('pageTitle').textContent = 'Modifier Catégorie';
                    document.getElementById('categoryId').value = cat.id;
                    document.getElementById('code').value = cat.code;
                    document.getElementById('libelle').value = cat.libelle;
                    document.getElementById('description').value = cat.description || '';
                    document.getElementById('actif').checked = cat.actif;
                },
                function() { showError('Chargement impossible'); }
            );
        }
    </script>
</body>
</html>
