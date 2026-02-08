<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <c:set var="isEdit" value="${not empty article and not empty article.id}"/>
    <title><c:out value="${isEdit ? 'Modifier article' : 'Nouvel article'}"/> - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
        <div class="page-header">
            <h1><c:out value="${isEdit ? 'Modifier article' : 'Nouvel article'}"/></h1>
        </div>

        <div class="form-container">
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
            <c:choose>
                <c:when test="${isEdit}">
                    <c:url var="formAction" value="/articles/${article.id}/update"/>
                </c:when>
                <c:otherwise>
                    <c:url var="formAction" value="/articles"/>
                </c:otherwise>
            </c:choose>
            <form method="POST" action="${formAction}">
                <div class="mb-3">
                    <label for="code" class="form-label">Code *</label>
                    <input type="text" class="form-control" id="code" name="code" value="<c:out value='${article.code}'/>" required>
                </div>

                <div class="mb-3">
                    <label for="name" class="form-label">Nom *</label>
                    <input type="text" class="form-control" id="name" name="name" value="<c:out value='${article.name}'/>" required>
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label">Description</label>
                    <textarea class="form-control" id="description" name="description" rows="3"><c:out value="${article.description}"/></textarea>
                </div>

                <div class="mb-3">
                    <label for="category" class="form-label">Catégorie d'article</label>
                    <div style="display: flex; gap: 10px; align-items: center;">
                        <select class="form-control" id="category" name="category.id" style="flex: 1;">
                            <option value="">-- Aucune catégorie --</option>
                            <c:forEach items="${categories}" var="cat">
                                <option value="${cat.id}" <c:if test="${not empty article.category and article.category.id == cat.id}">selected</c:if>>${cat.libelle}</option>
                            </c:forEach>
                        </select>
                        <a href="<c:url value='/admin/categories'/>" class="btn btn-sm btn-outline-secondary" title="Gérer les catégories">+</a>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="purchasePrice" class="form-label">Prix d'achat *</label>
                    <input type="number" step="0.01" class="form-control" id="purchasePrice" name="purchasePrice" value="<c:out value='${article.purchasePrice}'/>" required>
                </div>

                <div class="mb-3">
                    <label for="sellingPrice" class="form-label">Prix de vente *</label>
                    <input type="number" step="0.01" class="form-control" id="sellingPrice" name="sellingPrice" value="<c:out value='${article.sellingPrice}'/>" required>
                </div>

                <div class="mb-3">
                    <label for="minStock" class="form-label">Stock minimum</label>
                    <input type="number" class="form-control" id="minStock" name="minStock" value="<c:out value='${empty article.minStock ? 10 : article.minStock}'/>">
                </div>

                <div class="mb-3">
                    <label for="maxStock" class="form-label">Stock maximum</label>
                    <input type="number" class="form-control" id="maxStock" name="maxStock" value="<c:out value='${empty article.maxStock ? 1000 : article.maxStock}'/>">
                </div>

                <div class="mb-3 form-check">
                    <input type="checkbox" class="form-check-input" id="tracked" name="tracked" <c:if test="${article.tracked}">checked</c:if>>
                    <label class="form-check-label" for="tracked">Suivi par lot/numero de serie</label>
                </div>

                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary btn-lg">
                        <c:out value="${isEdit ? 'Enregistrer' : 'Creer l\\'article'}"/>
                    </button>
                    <a href="<c:url value='/articles'/>" class="btn btn-secondary">Annuler</a>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>


