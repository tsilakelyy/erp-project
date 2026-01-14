<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Purchase Orders - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Purchase Orders</span>
    </nav>

    <div class="container mt-4">
        <div class="mb-3">
            <a href="/erp-system/purchases/orders/new" class="btn btn-primary">+ New Order</a>
        </div>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Number</th>
                    <th>Supplier</th>
                    <th>Total Amount</th>
                    <th>Status</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${orders}" var="order">
                    <tr>
                        <td>${order.number}</td>
                        <td>${order.supplier.name}</td>
                        <td>$${order.totalAmount}</td>
                        <td><span class="badge bg-info">${order.status}</span></td>
                        <td>${order.orderDate}</td>
                        <td>
                            <a href="/erp-system/purchases/orders/${order.id}" class="btn btn-sm btn-info">View</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
