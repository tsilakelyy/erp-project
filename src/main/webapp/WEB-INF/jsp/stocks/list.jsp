<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Stocks - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Stock Management</span>
    </nav>

    <div class="container mt-4">
        <h4>Select Warehouse</h4>
        <div class="list-group">
            <c:forEach items="${warehouses}" var="warehouse">
                <a href="/erp-system/stocks/warehouse/${warehouse.id}" class="list-group-item list-group-item-action">
                    ${warehouse.name} - ${warehouse.site.name}
                </a>
            </c:forEach>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
