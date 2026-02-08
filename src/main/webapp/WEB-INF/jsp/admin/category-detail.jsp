<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catégorie - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>${category.libelle}</h1>
                <div>
                    <a href="<c:url value='/admin/categories'/>" class="btn btn-secondary">Retour</a>
                </div>
            </div>

            <c:if test="${param.success}">
                <div class="alert alert-success">Opération réussie</div>
            </c:if>
            <c:if test="${param.error}">
                <div class="alert alert-danger">${param.error}</div>
            </c:if>

            <div class="info-grid" style="margin-bottom: 30px;">
                <div class="info-item">
                    <label>Code:</label>
                    <strong>${category.code}</strong>
                </div>
                <div class="info-item">
                    <label>Description:</label>
                    <strong>${category.description}</strong>
                </div>
                <div class="info-item">
                    <label>État:</label>
                    <strong>
                        <c:if test="${category.actif}">
                            <span class="badge badge-success">Actif</span>
                        </c:if>
                        <c:if test="${!category.actif}">
                            <span class="badge badge-danger">Inactif</span>
                        </c:if>
                    </strong>
                </div>
            </div>

            <h2>Articles dans cette catégorie (${fn:length(articles)})</h2>

            <div class="table-wrapper">
                <c:if test="${not empty articles}">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Libellé</th>
                                <th>Description</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${articles}" var="article">
                                <tr data-category-id="${article.id}">
                                    <td><strong>${article.code}</strong></td>
                                    <td>
                                        <a href="<c:url value='/articles/${article.id}'/>" style="text-decoration: none;">
                                            ${article.libelle}
                                        </a>
                                    </td>
                                    <td>${article.description}</td>
                                    <td>
                                        <c:if test="${article.actif}">
                                            <span class="badge badge-success">Actif</span>
                                        </c:if>
                                        <c:if test="${!article.actif}">
                                            <span class="badge badge-danger">Inactif</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <a href="<c:url value='/articles/${article.id}'/>" class="btn btn-sm btn-info">Voir</a>
                                        <a href="<c:url value='/articles/${article.id}/edit'/>" class="btn btn-sm btn-warning">Modifier</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:if>
                <c:if test="${empty articles}">
                    <div class="alert alert-info">Aucun article dans cette catégorie</div>
                </c:if>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script>
    function enableInlineEditCategory(categoryId) {
        const row = document.querySelector(`[data-category-id="${categoryId}"]`);
        const cells = row.querySelectorAll('td');

        cells[1].innerHTML = `<input type='text' value='${cells[1].innerText}' class='form-control' id='libelle-${categoryId}' />`;
        cells[2].innerHTML = `<input type='text' value='${cells[2].innerText}' class='form-control' id='description-${categoryId}' />`;

        const actionsCell = cells[4];
        actionsCell.innerHTML = `
            <button class='btn btn-sm btn-success' onclick='saveCategory(${categoryId})'>Enregistrer</button>
            <button class='btn btn-sm btn-secondary' onclick='cancelEditCategory(${categoryId})'>Annuler</button>
        `;
    }
    </script>
</body>
</html>
