<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Users - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Users</span>
    </nav>

    <div class="container mt-4">
        <div class="mb-3">
            <a href="/erp-system/admin/users/new" class="btn btn-primary">+ New User</a>
        </div>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Name</th>
                    <th>Status</th>
                    <th>Last Login</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${users}" var="user">
                    <tr>
                        <td>${user.username}</td>
                        <td>${user.email}</td>
                        <td>${user.firstName} ${user.lastName}</td>
                        <td>
                            <c:if test="${user.active}">
                                <span class="badge bg-success">Active</span>
                            </c:if>
                            <c:if test="${!user.active}">
                                <span class="badge bg-danger">Inactive</span>
                            </c:if>
                        </td>
                        <td>${user.lastLogin}</td>
                        <td>
                            <a href="/erp-system/admin/users/${user.id}" class="btn btn-sm btn-info">View</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
