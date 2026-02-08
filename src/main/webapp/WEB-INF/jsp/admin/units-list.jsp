<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Units - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Units</span>
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
        <form method="POST" action="<c:url value='/admin/units'/>" class="mb-3">
            <div class="row">
                <div class="col-md-3">
                    <input type="text" name="code" class="form-control" placeholder="Code" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="name" class="form-control" placeholder="Name" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="symbol" class="form-control" placeholder="Symbol">
                </div>
                <div class="col-md-3">
                    <button type="submit" class="btn btn-primary">Add Unit</button>
                </div>
            </div>
        </form>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Symbol</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${units}" var="unit">
                    <tr>
                        <td>${unit.code}</td>
                        <td>${unit.name}</td>
                        <td>${unit.symbol}</td>
                        <td>
                            <c:if test="${unit.active}">
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



