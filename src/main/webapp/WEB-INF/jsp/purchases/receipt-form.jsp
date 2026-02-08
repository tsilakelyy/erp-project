<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bon de reception - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1 id="pageTitle">Nouveau bon de reception</h1>
                <a href="<c:url value='/purchases/receipts'/>" class="btn btn-secondary">Retour</a>
            </div>

            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" id="formError" data-error="<c:out value='${param.error}'/>"></div>
                <script>
                    (function() {
                        var el = document.getElementById('formError');
                        if (!el) return;
                        var raw = el.getAttribute('data-error') || '';
                        try { el.textContent = decodeURIComponent(raw.replace(/\\+/g, ' ')); }
                        catch (e) { el.textContent = raw; }
                    })();
                </script>
            </c:if>

            <form id="receiptForm" method="POST" action="<c:url value='/purchases/receipts/form'/>" class="form-container">
                <input type="hidden" id="receiptId" name="id">

                <div class="form-group">
                    <label for="commandeId">Commande d'achat *</label>
                    <select id="commandeId" name="commandeId" class="form-control" required>
                        <option value="">Selectionner</option>
                        <c:forEach items="${orders}" var="o">
                            <option value="${o.id}">
                                <c:out value="${o.numero}"/> (Fournisseur ID: <c:out value="${o.fournisseurId}"/>)
                            </option>
                        </c:forEach>
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

                <div class="form-group">
                    <label for="notes">Notes</label>
                    <textarea id="notes" name="notes" class="form-control" rows="3"></textarea>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Enregistrer</button>
                    <a href="<c:url value='/purchases/receipts'/>" class="btn btn-secondary">Annuler</a>
                </div>
            </form>
        </div>
    </div>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const recId = new URLSearchParams(window.location.search).get('id');
            if (recId) loadReceipt(recId);
        });

        function loadReceipt(id) {
            ajaxCall(APP_CONTEXT + '/purchases/receipts/api/' + id, 'GET', null,
                function(rec) {
                    document.getElementById('pageTitle').textContent = 'Modifier Bon de Reception';
                    document.getElementById('receiptId').value = rec.id;
                    document.getElementById('commandeId').value = rec.commandeId || '';
                    document.getElementById('entrepotId').value = rec.entrepotId || '';
                    document.getElementById('notes').value = rec.notes || '';
                },
                function() { showError('Chargement impossible'); }
            );
        }
    </script>
</body>
</html>

