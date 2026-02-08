<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <c:set var="isEdit" value="${not empty supplier && not empty supplier.id}" />
    <c:set var="formAction" value="/suppliers" />
    <c:if test="${isEdit}">
        <c:set var="formAction" value="/suppliers/${supplier.id}/update" />
    </c:if>
    <title><c:out value="${isEdit ? 'Modifier fournisseur' : 'Nouveau fournisseur'}"/> - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - <c:out value="${isEdit ? 'Modifier fournisseur' : 'Nouveau fournisseur'}"/></span>
    </nav>

    <div class="container mt-4">
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
        <form method="POST" action="<c:url value='${formAction}'/>">
            <div class="mb-3">
                <label class="form-label">Code *</label>
                <input type="text" class="form-control" name="code" value="<c:out value='${supplier.code}'/>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Nom *</label>
                <input type="text" class="form-control" name="name" value="<c:out value='${supplier.name}'/>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Email</label>
                <input type="email" class="form-control" name="email" value="<c:out value='${supplier.email}'/>">
            </div>

            <div class="mb-3">
                <label class="form-label">Telephone</label>
                <input type="text" class="form-control" name="phone" value="<c:out value='${supplier.phone}'/>">
            </div>

            <div class="mb-3">
                <label class="form-label">Adresse</label>
                <input type="text" class="form-control" name="address" value="<c:out value='${supplier.address}'/>">
            </div>

            <div class="mb-3">
                <label class="form-label">Ville</label>
                <input type="text" class="form-control" name="city" value="<c:out value='${supplier.city}'/>">
            </div>

            <div class="mb-3">
                <label class="form-label">Delai de paiement (jours)</label>
                <input type="number" class="form-control" name="paymentTermsDays" value="<c:out value='${supplier.paymentTermsDays != null ? supplier.paymentTermsDays : 30}'/>">
            </div>

            <button type="submit" class="btn btn-primary"><c:out value="${isEdit ? 'Mettre a jour' : 'Creer'}"/></button>
            <a href="<c:url value='/suppliers'/>" class="btn btn-secondary">Annuler</a>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </div>
</body>
</html>



