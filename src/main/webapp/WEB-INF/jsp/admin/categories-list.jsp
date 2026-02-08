<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catégories d'Articles - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Catégories d'Articles</h1>
                <a href="<c:url value='/admin/categories/new'/>" class="btn btn-primary">+ Nouvelle Catégorie</a>
            </div>

            <c:if test="${param.success}">
                <div class="alert alert-success">Opération réussie</div>
            </c:if>
            <c:if test="${param.error}">
                <div class="alert alert-danger">${param.error}</div>
            </c:if>

            <div class="table-wrapper">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Libellé</th>
                            <th>Description</th>
                            <th>Aktif</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${categories}" var="category">
                            <tr data-category-id="${category.id}">
                                <td><strong>${category.code}</strong></td>
                                <td>${category.libelle}</td>
                                <td>${category.description}</td>
                                <td>
                                    <c:if test="${category.actif}">
                                        <span class="badge badge-success">Actif</span>
                                    </c:if>
                                    <c:if test="${!category.actif}">
                                        <span class="badge badge-danger">Inactif</span>
                                    </c:if>
                                </td>
                                <td>
                                    <a href="<c:url value='/admin/categories/${category.id}'/>" class="btn btn-sm btn-primary">Voir</a>
                                    <a href="<c:url value='/admin/categories/form?id=${category.id}'/>" class="btn btn-sm btn-info">Modifier</a>
                                    <form method="POST" action="<c:url value='/admin/categories/${category.id}/delete'/>" style="display:inline;" onsubmit="return confirm('Confirmer la suppression ?');">
                                        <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <c:if test="${empty categories}">
                    <p class="text-center text-muted">Aucune catégorie trouvée</p>
                </c:if>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
</body>
</html>
