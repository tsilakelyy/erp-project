<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Listes de Prix - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Listes de Prix</h1>
                <a href="<c:url value='/admin/pricing-lists/new'/>" class="btn btn-primary">+ Nouvelle Liste</a>
            </div>

            <c:if test="${param.success}">
                <div class="alert alert-success">Opération réussie</div>
            </c:if>
            <c:if test="${param.error}">
                <div class="alert alert-danger">${param.error}</div>
            </c:if>

            <div class="filters">
                <form method="GET" class="form-inline">
                    <select name="type" class="form-control" style="margin-right: 10px;">
                        <option value="">-- Tous --</option>
                        <option value="VENTE" <c:if test="${selectedType == 'VENTE'}">selected</c:if>>Vente</option>
                        <option value="ACHAT" <c:if test="${selectedType == 'ACHAT'}">selected</c:if>>Achat</option>
                        <option value="GENERAL" <c:if test="${selectedType == 'GENERAL'}">selected</c:if>>Général</option>
                    </select>
                    <button type="submit" class="btn btn-secondary">Filtrer</button>
                </form>
            </div>

            <div class="table-wrapper">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Libellé</th>
                            <th>Type</th>
                            <th>Lignes</th>
                            <th>Défaut</th>
                            <th>Aktif</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pricingLists}" var="list">
                            <tr>
                                <td><strong>${list.code}</strong></td>
                                <td>${list.libelle}</td>
                                <td>
                                    <c:if test="${list.typeListe == 'VENTE'}">
                                        <span class="badge badge-success">Vente</span>
                                    </c:if>
                                    <c:if test="${list.typeListe == 'ACHAT'}">
                                        <span class="badge badge-info">Achat</span>
                                    </c:if>
                                    <c:if test="${list.typeListe == 'GENERAL'}">
                                        <span class="badge badge-warning">Général</span>
                                    </c:if>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty list.lines}">0</c:when>
                                        <c:otherwise>${fn:length(list.lines)}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:if test="${list.parDefaut}">
                                        <span class="badge badge-success">Défaut</span>
                                    </c:if>
                                </td>
                                <td>
                                    <c:if test="${list.actif}">
                                        <span class="badge badge-success">Actif</span>
                                    </c:if>
                                    <c:if test="${!list.actif}">
                                        <span class="badge badge-danger">Inactif</span>
                                    </c:if>
                                </td>
                                <td>
                                    <a href="<c:url value='/admin/pricing-lists/${list.id}'/>" class="btn btn-sm btn-primary">Détail</a>
                                    <a href="<c:url value='/admin/pricing-lists/${list.id}/edit'/>" class="btn btn-sm btn-info">Modifier</a>
                                    <form method="POST" action="<c:url value='/admin/pricing-lists/${list.id}/delete'/>" style="display:inline;" onsubmit="return confirm('Confirmer la suppression ?');">
                                        <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <c:if test="${empty pricingLists}">
                    <p class="text-center text-muted">Aucune liste de prix trouvée</p>
                </c:if>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>
</body>
</html>
