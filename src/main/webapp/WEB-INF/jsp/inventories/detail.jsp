<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Detail - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1 id="inventoryNumber">Inventory Details</h1>
                <a href="/erp/inventories/list" class="btn btn-secondary">Back</a>
            </div>

            <div id="inventoryDetails" class="detail-container">
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const invId = window.location.pathname.split('/').pop();
            loadInventoryDetail(invId);
        });

        function loadInventoryDetail(id) {
            ajaxCall('/erp/api/inventory-counts/' + id, 'GET', null,
                function(inv) {
                    document.getElementById('inventoryNumber').textContent = 'Inventory: ' + inv.numero;
                    const html = `
                        <div class="detail-row">
                            <div class="detail-item"><strong>Number:</strong> ${inv.numero}</div>
                            <div class="detail-item"><strong>Type:</strong> ${inv.typeInventaire}</div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-item"><strong>Warehouse:</strong> ${inv.entrepot}</div>
                            <div class="detail-item"><strong>Status:</strong> <span class="badge badge-info">${inv.statut}</span></div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-item"><strong>Start Date:</strong> ${inv.dateDebut}</div>
                            <div class="detail-item"><strong>End Date:</strong> ${inv.dateFin || 'Ongoing'}</div>
                        </div>
                    `;
                    document.getElementById('inventoryDetails').innerHTML = html;
                },
                function() { showError('Load failed'); }
            );
        }
    </script>
</body>
</html>
