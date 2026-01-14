<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Warehouse Detail - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1 id="warehouseName">Warehouse Details</h1>
                <div>
                    <a href="/erp/warehouses" class="btn btn-secondary">Back</a>
                    <button class="btn btn-warning" onclick="editWarehouse()">Edit</button>
                </div>
            </div>

            <div id="warehouseDetails" class="detail-container">
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        let currentWhId = null;

        document.addEventListener('DOMContentLoaded', function() {
            const whId = window.location.pathname.split('/').pop();
            loadWarehouseDetail(whId);
        });

        function loadWarehouseDetail(id) {
            currentWhId = id;
            ajaxCall('/erp/api/warehouses/' + id, 'GET', null,
                function(wh) {
                    document.getElementById('warehouseName').textContent = wh.nomDepot;
                    const capacityPercent = Math.round((wh.capaciteUtilisee / wh.capaciteMaximale) * 100);
                    const html = `
                        <div class="detail-row">
                            <div class="detail-item"><strong>Code:</strong> ${wh.code}</div>
                            <div class="detail-item"><strong>Name:</strong> ${wh.nomDepot}</div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-item"><strong>Type:</strong> ${wh.typeDepot}</div>
                            <div class="detail-item"><strong>Address:</strong> ${wh.adresse}</div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-item"><strong>Max Capacity:</strong> ${wh.capaciteMaximale}</div>
                            <div class="detail-item"><strong>Used Capacity:</strong> ${wh.capaciteUtilisee} (${capacityPercent}%)</div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-item"><strong>Status:</strong> <span class="badge ${wh.actif ? 'badge-success' : 'badge-secondary'}">${wh.actif ? 'Active' : 'Inactive'}</span></div>
                        </div>
                    `;
                    document.getElementById('warehouseDetails').innerHTML = html;
                },
                function() { showError('Load failed'); }
            );
        }

        function editWarehouse() {
            navigateTo('/erp/warehouses/form?id=' + currentWhId);
        }
    </script>
</body>
</html>
