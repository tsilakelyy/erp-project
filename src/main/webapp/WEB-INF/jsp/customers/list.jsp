<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Clients - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Clients</span>
    </nav>

    <div class="container mt-4">
        <c:if test="${param.success == '1'}">
            <div class="alert alert-success">Insertion reussie.</div>
        </c:if>
        <div class="mb-3">
            <a href="<c:url value='/customers/new'/>" class="btn btn-primary">+ Nouveau client</a>
        </div>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Entreprise</th>
                    <th>Email</th>
                    <th>Telephone</th>
                    <th>Statut</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${customers}" var="customer">
                    <tr>
                        <td>${customer.code}</td>
                        <td>${customer.nomEntreprise}</td>
                        <td>${customer.email}</td>
                        <td>${customer.telephone}</td>
                        <td>
                            <c:if test="${customer.active}">
                                <span class="badge bg-success">Actif</span>
                            </c:if>
                            <c:if test="${!customer.active}">
                                <span class="badge bg-danger">Inactif</span>
                            </c:if>
                        </td>
                        <td>
                            <a href="<c:url value='/customers/${customer.id}'/>" class="btn btn-sm btn-info">Voir</a>
                            <a href="<c:url value='/customers/${customer.id}/edit'/>" class="btn btn-sm btn-warning">Modifier</a>
                            <form method="POST" action="<c:url value='/customers/${customer.id}/deactivate'/>" style="display:inline;">
                                <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                            </form>
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
