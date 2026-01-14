<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Order Detail - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1 id="orderNumber">Sales Order Details</h1>
                <a href="/erp/sales/orders-list" class="btn btn-secondary">Back</a>
            </div>

            <div id="orderDetails" class="detail-container">
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const orderId = window.location.pathname.split('/').pop();
            loadOrderDetail(orderId);
        });

        function loadOrderDetail(id) {
            ajaxCall('/erp/api/sales-orders/' + id, 'GET', null,
                function(order) {
                    document.getElementById('orderNumber').textContent = 'Sales Order: ' + order.numero;
                    const html = `
                        <div class="detail-row">
                            <div class="detail-item"><strong>Order Number:</strong> ${order.numero}</div>
                            <div class="detail-item"><strong>Status:</strong> <span class="badge badge-info">${order.statut}</span></div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-item"><strong>Customer:</strong> ${order.client}</div>
                            <div class="detail-item"><strong>Warehouse:</strong> ${order.entrepot}</div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-item"><strong>Amount HT:</strong> ${order.montantHt}</div>
                            <div class="detail-item"><strong>VAT:</strong> ${order.montantTva}</div>
                            <div class="detail-item"><strong>Amount TTC:</strong> ${order.montantTtc}</div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-item"><strong>Due Date:</strong> ${order.dateEcheance}</div>
                        </div>
                    `;
                    document.getElementById('orderDetails').innerHTML = html;
                },
                function() { showError('Load failed'); }
            );
        }
    </script>
</body>
</html>
