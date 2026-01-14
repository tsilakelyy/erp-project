<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Purchase Order Detail - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Order ${order.number}</span>
    </nav>

    <div class="container mt-4">
        <div class="row mb-3">
            <div class="col-md-8">
                <h4>Order Details</h4>
                <dl class="row">
                    <dt class="col-sm-3">Number:</dt>
                    <dd class="col-sm-9">${order.number}</dd>

                    <dt class="col-sm-3">Supplier:</dt>
                    <dd class="col-sm-9">${order.supplier.name}</dd>

                    <dt class="col-sm-3">Status:</dt>
                    <dd class="col-sm-9"><span class="badge bg-info">${order.status}</span></dd>

                    <dt class="col-sm-3">Order Date:</dt>
                    <dd class="col-sm-9">${order.orderDate}</dd>

                    <dt class="col-sm-3">Total Amount:</dt>
                    <dd class="col-sm-9">$${order.totalAmount}</dd>
                </dl>
            </div>
            <div class="col-md-4">
                <h4>Actions</h4>
                <c:if test="${order.status == 'DRAFT'}">
                    <form method="POST" action="/erp-system/purchases/orders/${order.id}/submit" style="display:inline;">
                        <button type="submit" class="btn btn-success">Submit</button>
                    </form>
                </c:if>
                <c:if test="${order.status == 'SUBMITTED'}">
                    <form method="POST" action="/erp-system/purchases/orders/${order.id}/approve" style="display:inline;">
                        <button type="submit" class="btn btn-success">Approve</button>
                    </form>
                </c:if>
            </div>
        </div>

        <h4>Order Lines</h4>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Article</th>
                    <th>Quantity</th>
                    <th>Unit Price</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${order.lines}" var="line">
                    <tr>
                        <td>${line.article.name}</td>
                        <td>${line.orderedQuantity}</td>
                        <td>$${line.unitPrice}</td>
                        <td>$${line.totalPrice}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <a href="/erp-system/purchases/orders" class="btn btn-secondary">Back</a>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
