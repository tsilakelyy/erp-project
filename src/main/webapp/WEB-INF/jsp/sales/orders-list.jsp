<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Commandes de vente - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Commandes de vente</span>
    </nav>

    <div class="container mt-4">
        <div class="mb-3">
            <a href="<c:url value='/sales/proformas'/>" class="btn btn-primary">+ Nouvelle commande (via devis)</a>
        </div>
        <c:if test="${param.success == '1'}">
            <div class="alert alert-success">Insertion reussie.</div>
        </c:if>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Numero</th>
                    <th>Client</th>
                    <th>Montant TTC</th>
                    <th>Statut</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${orders}" var="order">
                    <tr data-order-id="${order.id}">
                        <td>${order.numero}</td>
                        <td>${order.clientId}</td>
                        <td>Ar ${order.montantTtc}</td>
                        <td><span class="badge bg-info">${order.statut}</span></td>
                        <td>${order.dateCommande}</td>
                        <td>
                            <a href="<c:url value='/sales/orders/${order.id}'/>" class="btn btn-sm btn-info">Voir</a>
                            <button class="btn btn-sm btn-warning" onclick="enableInlineEdit('${order.id}')">Modifier</button>
                            <form method="POST" action="<c:url value='/sales/orders/${order.id}/cancel'/>" style="display:inline;">
                                <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function enableInlineEdit(orderId) {
            const row = document.querySelector(`[data-order-id="${orderId}"]`);
            const cells = row.querySelectorAll('td');
            const currentStatus = cells[3].innerText.trim();

            // Replace text with input fields for editing
            cells[1].innerHTML = `<input type='text' value='${cells[1].innerText}' class='form-control' id='client-${orderId}' />`;
            cells[2].innerHTML = `<input type='text' value='${cells[2].innerText.replace('Ar ', '')}' class='form-control' id='montant-${orderId}' />`;
            cells[3].innerHTML = `<select class='form-select' id='statut-${orderId}'>
                                    <option value='EN_ATTENTE'>EN_ATTENTE</option>
                                    <option value='LIVREE'>LIVREE</option>
                                 </select>`;

            // Set the current status as selected
            document.getElementById(`statut-${orderId}`).value = currentStatus;

            // Change the Modify button to Save and Cancel buttons
            const actionsCell = cells[5];
            actionsCell.innerHTML = `
                <button class='btn btn-sm btn-success' onclick='saveOrder(${orderId})'>Enregistrer</button>
                <button class='btn btn-sm btn-secondary' onclick='cancelEdit(${orderId})'>Annuler</button>
            `;
        }

        function saveOrder(orderId) {
            const client = document.getElementById(`client-${orderId}`).value;
            const montant = document.getElementById(`montant-${orderId}`).value;
            const statut = document.getElementById(`statut-${orderId}`).value;

            fetch(`/sales/orders/${orderId}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    clientId: client,
                    montantTtc: montant,
                    statut: statut
                })
            })
            .then(response => {
                if (response.ok) {
                    location.reload();
                } else {
                    alert('Erreur lors de la mise à jour de la commande.');
                }
            });
        }

        function cancelEdit(orderId) {
            location.reload();
        }
    </script>
    </div>
</body>
</html>
