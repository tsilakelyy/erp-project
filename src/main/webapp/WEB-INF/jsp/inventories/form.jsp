<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Counts - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/css/style-tables.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Physical Inventories</h1>
                <button class="btn btn-primary" onclick="startInventory()">Start Physical Inventory</button>
            </div>

            <div id="inventoriesContainer" class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Inventory Number</th>
                            <th>Type</th>
                            <th>Warehouse</th>
                            <th>Start Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="inventoriesTableBody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadInventories();
        });

        function loadInventories() {
            ajaxCall('/erp/api/inventory-counts', 'GET', null,
                function(response) {
                    const inventories = response.data || response;
                    renderInventoriesTable(inventories);
                },
                function(error) { showError('Load failed'); }
            );
        }

        function renderInventoriesTable(inventories) {
            const tbody = document.getElementById('inventoriesTableBody');
            tbody.innerHTML = '';

            if (!inventories || inventories.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">No inventories found</td></tr>';
                return;
            }

            inventories.forEach(inv => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td><strong>${inv.numero}</strong></td>
                    <td>${inv.typeInventaire}</td>
                    <td>${inv.entrepot}</td>
                    <td>${inv.dateDebut}</td>
                    <td><span class="badge badge-info">${inv.statut}</span></td>
                    <td>
                        <button class="btn btn-sm btn-info" onclick="viewInventory(${inv.id})">View</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        function startInventory() {
            const warehouseId = prompt('Enter Warehouse ID:');
            if (warehouseId) {
                ajaxCall('/erp/api/inventory-counts', 'POST', 
                    JSON.stringify({typeInventaire: 'TOURNANT', entrepotId: warehouseId}),
                    function() {
                        showSuccess('Inventory started');
                        loadInventories();
                    },
                    function() { showError('Failed to start inventory'); }
                );
            }
        }

        function viewInventory(id) {
            navigateTo('/erp/inventories/detail/' + id);
        }
    </script>
</body>
</html>
