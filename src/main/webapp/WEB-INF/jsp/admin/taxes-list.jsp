<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Taxes - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Taxes</span>
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
        <form method="POST" action="<c:url value='/admin/taxes'/>" class="mb-3">
            <div class="row">
                <div class="col-md-2">
                    <input type="text" name="code" class="form-control" placeholder="Code" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="name" class="form-control" placeholder="Libelle" required>
                </div>
                <div class="col-md-2">
                    <input type="number" step="0.01" name="rate" class="form-control" placeholder="Taux %" required>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary">Ajouter</button>
                </div>
            </div>
        </form>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Libelle</th>
                    <th>Taux</th>
                    <th>Statut</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${taxes}" var="tax">
                    <tr>
                        <td>${tax.code}</td>
                        <td>${tax.name}</td>
                        <td>${tax.rate}%</td>
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
    </div>
</body>
</html>



