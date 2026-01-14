<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Taxes - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Taxes</span>
    </nav>

    <div class="container mt-4">
        <form method="POST" action="/erp-system/admin/taxes" class="mb-3">
            <div class="row">
                <div class="col-md-2">
                    <input type="text" name="code" class="form-control" placeholder="Code" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="name" class="form-control" placeholder="Name" required>
                </div>
                <div class="col-md-2">
                    <input type="number" step="0.01" name="rate" class="form-control" placeholder="Rate %" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="description" class="form-control" placeholder="Description">
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary">Add Tax</button>
                </div>
            </div>
        </form>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Rate</th>
                    <th>Description</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${taxes}" var="tax">
                    <tr>
                        <td>${tax.code}</td>
                        <td>${tax.name}</td>
                        <td>${tax.rate}%</td>
                        <td>${tax.description}</td>
                        <td>
                            <c:if test="${tax.active}">
                                <span class="badge bg-success">Active</span>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
