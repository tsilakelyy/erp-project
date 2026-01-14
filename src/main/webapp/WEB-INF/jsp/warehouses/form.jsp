<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Warehouse Form - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/css/style-forms.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1 id="pageTitle">New Warehouse</h1>
            </div>

            <form id="warehouseForm" onsubmit="submitWarehouseForm(event)">
                <input type="hidden" id="warehouseId" name="id">

                <div class="form-row">
                    <div class="form-group">
                        <label for="code">Code *</label>
                        <input type="text" id="code" name="code" class="form-control" required maxlength="50">
                    </div>
                    <div class="form-group">
                        <label for="nomDepot">Name *</label>
                        <input type="text" id="nomDepot" name="nomDepot" class="form-control" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="adresse">Address</label>
                    <input type="text" id="adresse" name="adresse" class="form-control">
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="typeDepot">Type *</label>
                        <select id="typeDepot" name="typeDepot" class="form-control" required>
                            <option value="">-- Select Type --</option>
                            <option value="PRINCIPAL">Principal</option>
                            <option value="SECONDAIRE">Secondary</option>
                            <option value="TRANSIT">Transit</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="capaciteMaximale">Max Capacity *</label>
                        <input type="number" id="capaciteMaximale" name="capaciteMaximale" class="form-control" required>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save</button>
                    <a href="/erp/warehouses" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const whId = new URLSearchParams(window.location.search).get('id');
            if (whId) loadWarehouse(whId);
        });

        function loadWarehouse(id) {
            ajaxCall('/erp/api/warehouses/' + id, 'GET', null,
                function(wh) {
                    document.getElementById('pageTitle').textContent = 'Edit Warehouse';
                    document.getElementById('warehouseId').value = wh.id;
                    document.getElementById('code').value = wh.code;
                    document.getElementById('nomDepot').value = wh.nomDepot;
                    document.getElementById('adresse').value = wh.adresse || '';
                    document.getElementById('typeDepot').value = wh.typeDepot;
                    document.getElementById('capaciteMaximale').value = wh.capaciteMaximale;
                },
                function() { showError('Load failed'); }
            );
        }

        function submitWarehouseForm(event) {
            event.preventDefault();
            const formData = {
                code: document.getElementById('code').value,
                nomDepot: document.getElementById('nomDepot').value,
                adresse: document.getElementById('adresse').value,
                typeDepot: document.getElementById('typeDepot').value,
                capaciteMaximale: parseFloat(document.getElementById('capaciteMaximale').value)
            };

            const whId = document.getElementById('warehouseId').value;
            const method = whId ? 'PUT' : 'POST';
            const url = whId ? '/erp/api/warehouses/' + whId : '/erp/api/warehouses';

            ajaxCall(url, method, JSON.stringify(formData),
                function() {
                    showSuccess('Saved successfully');
                    setTimeout(() => navigateTo('/erp/warehouses'), 1500);
                },
                function() { showError('Save failed'); }
            );
        }
    </script>
</body>
</html>
