<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Detail article - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
        <div class="page-header">
            <h1>${article.name}</h1>
        </div>

        <div class="detail-container">
            <div class="detail-row">
                <span class="detail-label">Code :</span>
                <span class="detail-value">${article.code}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Description :</span>
                <span class="detail-value">${article.description}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Catégorie :</span>
                <span class="detail-value">
                    <c:if test="${not empty article.category}">
                        <a href="<c:url value='/admin/categories/${article.category.id}'/>" style="text-decoration: none;">
                            ${article.category.libelle}
                        </a>
                    </c:if>
                    <c:if test="${empty article.category}">
                        <small class="text-muted">Non catégorisé</small>
                    </c:if>
                </span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Unite :</span>
                <span class="detail-value">${article.uniteMesure}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Prix d'achat :</span>
                <span class="detail-value">Ar ${article.purchasePrice}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Prix de vente :</span>
                <span class="detail-value">Ar ${article.sellingPrice}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Stock minimum :</span>
                <span class="detail-value">${article.minStock}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Stock maximum :</span>
                <span class="detail-value">${article.maxStock}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Statut :</span>
                <span class="detail-value">
                    <c:if test="${article.active}">
                        <span class="badge bg-success">Actif</span>
                    </c:if>
                    <c:if test="${!article.active}">
                        <span class="badge bg-danger">Inactif</span>
                    </c:if>
                </span>
            </div>

            <div style="margin-top: 20px;">
                <a href="<c:url value='/articles/${article.id}/edit'/>" class="btn btn-primary">Modifier</a>
                <a href="<c:url value='/articles'/>" class="btn btn-secondary">Retour</a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
