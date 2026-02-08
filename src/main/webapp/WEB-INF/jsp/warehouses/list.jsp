<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Entrepots - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Entrepots</h1>
                <a href="<c:url value='/warehouses/form'/>" class="btn btn-primary">+ Nouvel entrepot</a>
            </div>

            <c:if test="${param.success == '1'}">
                <div class="alert alert-success">Enregistrement effectue avec succes.</div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" id="listError" data-error="<c:out value='${param.error}'/>"></div>
                <script>
                    (function() {
                        var el = document.getElementById('listError');
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

            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Nom</th>
                            <th>Adresse</th>
                            <th>Type</th>
                            <th>Capacite</th>
                            <th>Statut</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${warehouses}" var="wh">
                            <tr data-warehouse-id="${wh.id}">
                                <td><strong>${wh.code}</strong></td>
                                <td>${wh.nomDepot}</td>
                                <td><c:out value="${wh.adresse}" default="-" /></td>
                                <td><c:out value="${wh.typeDepot}" default="-" /></td>
                                <td><c:out value="${wh.capaciteMaximale}" default="-" /></td>
                                <td><span class="badge ${wh.actif ? 'badge-success' : 'badge-secondary'}">${wh.actif ? 'Actif' : 'Inactif'}</span></td>
                                <td>
                                    <a href="<c:url value='/warehouses/detail/${wh.id}'/>" class="btn btn-sm btn-info">Voir</a>
                                    <a href="<c:url value='/warehouses/form?id=${wh.id}'/>" class="btn btn-sm btn-warning">Modifier</a>
                                    <form method="POST" action="<c:url value='/warehouses/${wh.id}/delete'/>" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        function enableInlineEditWarehouse(warehouseId) {
            const row = document.querySelector(`[data-warehouse-id="${warehouseId}"]`);
            const cells = row.querySelectorAll('td');

            cells[1].innerHTML = `<input type='text' value='${cells[1].innerText}' class='form-control' id='type-${warehouseId}' />`;
            cells[2].innerHTML = `<input type='text' value='${cells[2].innerText}' class='form-control' id='capacity-${warehouseId}' />`;

            const actionsCell = cells[6];
            actionsCell.innerHTML = `
                <button class='btn btn-sm btn-success' onclick='saveWarehouse(${warehouseId})'>Enregistrer</button>
                <button class='btn btn-sm btn-secondary' onclick='cancelEditWarehouse(${warehouseId})'>Annuler</button>
            `;
        }

        function saveWarehouse(warehouseId) {
            const typeDepot = document.getElementById(`type-${warehouseId}`).value;
            const capaciteMaximale = document.getElementById(`capacity-${warehouseId}`).value;

            fetch(`/api/warehouses/${warehouseId}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    typeDepot: typeDepot,
                    capaciteMaximale: capaciteMaximale
                })
            })
            .then(response => {
                if (response.ok) {
                    location.reload();
                } else {
                    alert('Erreur lors de la mise à jour de l\'entrepôt.');
                }
            })
            .catch(error => console.error('Error:', error));
        }

        function cancelEditWarehouse(warehouseId) {
            location.reload();
        }
    </script>
</body>
</html>
