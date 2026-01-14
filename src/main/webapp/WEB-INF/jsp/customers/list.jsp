<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customers - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Customers</span>
    </nav>

    <div class="container mt-4">
        <div class="mb-3">
            <a href="/erp-system/customers/new" class="btn btn-primary">+ New Customer</a>
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
                <c:forEach items="${customers}" var="customer">
                    <tr>
                        <td>${customer.code}</td>
                        <td>${customer.name}</td>
                        <td>${customer.email}</td>
                        <td>${customer.phone}</td>
                        <td>
                            <c:if test="${customer.active}">
                                <span class="badge bg-success">Active</span>
                            </c:if>
                        </td>
                        <td>
                            <a href="/erp-system/customers/${customer.id}" class="btn btn-sm btn-info">View</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
