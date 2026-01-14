<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Orders - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/css/style-tables.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Purchase Orders</h1>
                <button class="btn btn-primary" onclick="navigateTo('/erp/purchases/form')">New Purchase Order</button>
            </div>

            <div id="ordersContainer" class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Order Number</th>
                            <th>Supplier</th>
                            <th>Amount</th>
                            <th>Due Date</th>
                            <th>Status</th>
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
            loadPurchaseOrders();
        });

        function loadPurchaseOrders() {
            ajaxCall('/erp/api/purchase-orders', 'GET', null,
                function(response) {
                    const orders = response.data || response;
                    renderOrdersTable(orders);
                },
                function(error) { showError('Load failed'); }
            );
        }

        function renderOrdersTable(orders) {
            const tbody = document.getElementById('ordersTableBody');
            tbody.innerHTML = '';

            if (!orders || orders.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">No purchase orders found</td></tr>';
                return;
            }

            orders.forEach(order => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td><strong>${order.numero}</strong></td>
                    <td>${order.fournisseur}</td>
                    <td>${order.montantTtc}</td>
                    <td>${order.dateEcheance}</td>
                    <td><span class="badge badge-info">${order.statut}</span></td>
                    <td>
                        <button class="btn btn-sm btn-info" onclick="viewOrder(${order.id})">View</button>
                        <button class="btn btn-sm btn-warning" onclick="editOrder(${order.id})">Edit</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        function viewOrder(id) {
            navigateTo('/erp/purchases/detail/' + id);
        }

        function editOrder(id) {
            navigateTo('/erp/purchases/form?id=' + id);
        }
    </script>
</body>
</html>
