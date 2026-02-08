<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Commandes de vente - ERP</title>
<jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Commandes de vente</h1>
                <button class="btn btn-primary" onclick="navigateTo('/erp-system/sales/orders/new')">Nouvelle commande</button>
            </div>

            <div id="ordersContainer" class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Numero</th>
                            <th>Client</th>
                            <th>Montant</th>
                            <th>Date</th>
                            <th>Statut</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ordersTableBody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadSalesOrders();
        });

        function loadSalesOrders() {
            ajaxCall('/erp-system/api/sales-orders', 'GET', null,
                function(response) {
                    const orders = response.data || response;
                    renderOrdersTable(orders);
                },
                function() { showError('Chargement impossible'); }
            );
        }

        function renderOrdersTable(orders) {
            const tbody = document.getElementById('ordersTableBody');
            tbody.innerHTML = '';

            if (!orders || orders.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">Aucune commande</td></tr>';
                return;
            }

            orders.forEach(order => {
                const row = document.createElement('tr');
                const deliveryDate = order.dateLivraison ? new Date(order.dateLivraison).toLocaleDateString() : '-';
                row.innerHTML = `
                    <td><strong>\${order.numero}</strong></td>
                    <td>\${order.clientLibelle || '-'}</td>
                    <td>\${order.montantTotal || 0}</td>
                    <td>\${deliveryDate}</td>
                    <td><span class="badge badge-info">\${order.statut}</span></td>
                    <td>
                        <button class="btn btn-sm btn-info" onclick="viewOrder(\${order.id})">Voir</button>
                        <button class="btn btn-sm btn-warning" onclick="editOrder(\${order.id})">Modifier</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        function viewOrder(id) {
            navigateTo('/erp-system/sales/orders/' + id);
        }

        function editOrder(id) {
            navigateTo('/erp-system/sales/orders/new?id=' + id);
        }
    </script>
    
    <!-- JS Commons -->
    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script src="<c:url value='/assets/js/tables.js'/>"></script>
</body>
</html>
