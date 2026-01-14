<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Suppliers - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Suppliers</span>
    </nav>

    <div class="container mt-4">
        <div class="mb-3">
            <a href="/erp-system/suppliers/new" class="btn btn-primary">+ New Supplier</a>
        </div>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${suppliers}" var="supplier">
                    <tr>
                        <td>${supplier.code}</td>
                        <td>${supplier.name}</td>
                        <td>${supplier.email}</td>
                        <td>${supplier.phone}</td>
                        <td>
                            <c:if test="${supplier.active}">
                                <span class="badge bg-success">Active</span>
                            </c:if>
                        </td>
                        <td>
                            <a href="/erp-system/suppliers/${supplier.id}" class="btn btn-sm btn-info">View</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
