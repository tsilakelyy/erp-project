<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Inventories - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Inventories</span>
    </nav>

    <div class="container mt-4">
        <div class="mb-3">
            <a href="/erp-system/inventories/new" class="btn btn-primary">+ New Inventory</a>
        </div>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Number</th>
                    <th>Warehouse</th>
                    <th>Type</th>
                    <th>Status</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${inventories}" var="inventory">
                    <tr>
                        <td>${inventory.number}</td>
                        <td>${inventory.warehouse.name}</td>
                        <td>${inventory.type}</td>
                        <td><span class="badge bg-success">${inventory.status}</span></td>
                        <td>${inventory.inventoryDate}</td>
                        <td>
                            <a href="/erp-system/inventories/${inventory.id}" class="btn btn-sm btn-info">View</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
