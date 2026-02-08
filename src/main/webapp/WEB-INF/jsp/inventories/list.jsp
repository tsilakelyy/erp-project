<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventaires - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
        <div class="page-header">
            <h1>Inventaires</h1>
            <a href="<c:url value='/inventories/new'/>" class="btn btn-primary">+ Nouvel inventaire</a>
        </div>
        <c:if test="${param.success == '1'}">
            <div class="alert alert-success">Insertion reussie.</div>
        </c:if>

            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Numero</th>
                            <th>Entrepot ID</th>
                            <th>Type</th>
                            <th>Statut</th>
                            <th>Date debut</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${inventories}" var="inventory">
                            <tr>
                                <td>${inventory.numero}</td>
                                <td>${inventory.entrepotId}</td>
                                <td>${inventory.typeInventaire}</td>
                                <td>
                                    <span class="badge bg-success">${inventory.statut}</span>
                                </td>
                                <td>${inventory.dateDebut}</td>
                                <td>
                                    <a href="<c:url value='/inventories/${inventory.id}'/>" class="btn btn-sm btn-info text-white">Voir</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
