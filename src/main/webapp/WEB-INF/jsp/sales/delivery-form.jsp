<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Livraison - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1 id="pageTitle">Nouvelle Livraison</h1>
                <a href="<c:url value='/sales/deliveries'/>" class="btn btn-secondary">Retour</a>
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
                <form id="deliveryForm" method="POST" action="<c:url value='/sales/deliveries/form'/>">
                    <input type="hidden" id="deliveryId" name="id">

                    <div class="form-group">
                        <label>Numéro *</label>
                        <input type="text" id="numero" name="numero" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label>Statut *</label>
                        <select id="statut" name="statut" class="form-control" required>
                            <option value="">-- Sélectionner --</option>
                            <option value="EN_ATTENTE">En Attente</option>
                            <option value="EN_COURS">En Cours</option>
                            <option value="EXPEDIEE">Expédiée</option>
                            <option value="LIVREE">Livrée</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Commande ID</label>
                        <input type="number" id="commandeClientId" name="commandeClientId" class="form-control">
                    </div>

                    <div class="form-group">
                        <label>Entrepôt ID</label>
                        <input type="number" id="entrepotId" name="entrepotId" class="form-control">
                    </div>

                    <div class="form-group">
                        <label>Date Livraison</label>
                        <input type="date" id="dateLivraison" name="dateLivraison" class="form-control">
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Enregistrer</button>
                        <a href="<c:url value='/sales/deliveries'/>" class="btn btn-secondary">Annuler</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const delId = new URLSearchParams(window.location.search).get('id');
            if (delId) loadDelivery(delId);
        });

        function loadDelivery(id) {
            ajaxCall(APP_CONTEXT + '/api/deliveries/' + id, 'GET', null,
                function(del) {
                    document.getElementById('pageTitle').textContent = 'Modifier Livraison';
                    document.getElementById('deliveryId').value = del.id;
                    document.getElementById('numero').value = del.numero;
                    document.getElementById('statut').value = del.statut;
                    document.getElementById('commandeClientId').value = del.commandeClientId || '';
                    document.getElementById('entrepotId').value = del.entrepotId || '';
                    document.getElementById('dateLivraison').value = del.dateLivraison || '';
                },
                function() { showError('Chargement impossible'); }
            );
        }
    </script>
</body>
</html>
