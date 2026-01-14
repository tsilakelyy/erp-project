<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Warehouses - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/css/style-tables.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Warehouses</h1>
                <button class="btn btn-primary" onclick="navigateTo('/erp/warehouses/form')">New Warehouse</button>
            </div>

            <div id="warehousesContainer" class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Name</th>
                            <th>Address</th>
                            <th>Type</th>
                            <th>Capacity</th>
                            <th>Used %</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="warehousesTableBody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadWarehouses();
        });

        function loadWarehouses() {
            ajaxCall('/erp/api/warehouses', 'GET', null,
                function(response) {
                    const warehouses = response.data || response;
                    renderWarehousesTable(warehouses);
                },
                function(error) { showError('Load failed'); }
            );
        }

        function renderWarehousesTable(warehouses) {
            const tbody = document.getElementById('warehousesTableBody');
            tbody.innerHTML = '';

            if (!warehouses || warehouses.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8">No warehouses found</td></tr>';
                return;
            }

            warehouses.forEach(wh => {
                const capacityPercent = Math.round((wh.capaciteUtilisee / wh.capaciteMaximale) * 100);
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td><strong>${wh.code}</strong></td>
                    <td>${wh.nomDepot}</td>
                    <td>${wh.adresse}</td>
                    <td>${wh.typeDepot}</td>
                    <td>${wh.capaciteMaximale}</td>
                    <td><div class="progress-bar" style="width:${capacityPercent}%">${capacityPercent}%</div></td>
                    <td><span class="badge ${wh.actif ? 'badge-success' : 'badge-secondary'}">${wh.actif ? 'Active' : 'Inactive'}</span></td>
                    <td>
                        <button class="btn btn-sm btn-info" onclick="viewWarehouse(${wh.id})">View</button>
                        <button class="btn btn-sm btn-warning" onclick="editWarehouse(${wh.id})">Edit</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        function viewWarehouse(id) {
            navigateTo('/erp/warehouses/detail/' + id);
        }

        function editWarehouse(id) {
            navigateTo('/erp/warehouses/form?id=' + id);
        }
    </script>
</body>
</html>
