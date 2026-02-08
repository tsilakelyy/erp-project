<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Articles - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
        <div class="page-header">
            <h1>Articles</h1>
            <div>
            <a href="<c:url value='/articles/new'/>" class="btn btn-primary">+ Nouvel article</a>
            <a href="<c:url value='/logout'/>" class="btn btn-danger" style="margin-left: 10px;">Deconnexion</a>
            </div>
        </div>
        <c:if test="${param.success == '1'}">
            <div class="alert alert-success">Insertion reussie.</div>
        </c:if>

        <div class="table-container">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Code</th>
                        <th>Nom</th>
                        <th>Catégorie</th>
                        <th>Unite</th>
                        <th>Prix d'achat</th>
                        <th>Prix de vente</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${articles}" var="article">
                        <tr>
                            <td>${article.code}</td>
                            <td>${article.libelle}</td>
                            <td>
                                <c:if test="${not empty article.category}">
                                    <a href="<c:url value='/admin/categories/${article.category.id}'/>" style="text-decoration: none;">
                                        ${article.category.libelle}
                                    </a>
                                </c:if>
                                <c:if test="${empty article.category}">
                                    <small class="text-muted">--</small>
                                </c:if>
                            </td>
                            <td>${article.uniteMesure}</td>
                            <td>Ar ${article.prixUnitaire}</td>
                            <td>Ar ${article.prixUnitaire}</td>
                            <td>
                                <c:if test="${article.actif}">
                                    <span class="badge bg-success">Actif</span>
                                </c:if>
                                <c:if test="${!article.actif}">
                                    <span class="badge bg-danger">Inactif</span>
                                </c:if>
                            </td>
                        <td>
                            <a href="<c:url value='/articles/${article.id}'/>" class="btn btn-sm btn-info">Voir</a>
                            <a href="<c:url value='/articles/${article.id}/edit'/>" class="btn btn-sm btn-warning">Modifier</a>
                            <form method="POST" action="<c:url value='/articles/${article.id}/deactivate'/>" style="display:inline;">
                                <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                            </form>
                        </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
