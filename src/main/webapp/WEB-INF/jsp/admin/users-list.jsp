<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Users - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Users</span>
    </nav>

    <div class="container mt-4">
        <c:if test="${param.success == '1'}">
            <div class="alert alert-success">Insertion reussie.</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger" id="formError" data-error="<c:out value='${param.error}'/>"></div>
            <script>
                (function() {
                    var el = document.getElementById('formError');
                    if (!el) return;
                    var raw = el.getAttribute('data-error') || '';
                    try {
                        el.textContent = decodeURIComponent(raw.replace(/\\+/g, ' '));
                    } catch (e) {
                        el.textContent = raw;
                    }
                })();
            </script>
        </c:if>
        <div class="mb-3">
            <a href="<c:url value='/admin/users/new'/>" class="btn btn-primary">+ Nouvel utilisateur</a>
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
                        <td>${user.login}</td>
                        <td>${user.email}</td>
                        <td>${user.nom} ${user.prenom}</td>
                        <td>
                            <c:if test="${user.active}">
                                <span class="badge bg-success">Active</span>
                            </c:if>
                            <c:if test="${!user.active}">
                                <span class="badge bg-danger">Inactive</span>
                            </c:if>
                        </td>
                        <td>${user.dateLastLogin}</td>
                        <td>
                            <a href="<c:url value='/admin/users/${user.id}'/>" class="btn btn-sm btn-info">View</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </div>
</body>
</html>




