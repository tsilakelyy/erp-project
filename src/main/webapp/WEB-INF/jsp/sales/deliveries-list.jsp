<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Livraisons - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Livraisons</h1>
                <a href="<c:url value='/sales/orders'/>" class="btn btn-secondary">Commandes</a>
            </div>

            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Commande ID</th>
                        <th>Entrepot ID</th>
                        <th>Date livraison</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${deliveries}" var="delivery">
                        <tr data-delivery-id="${delivery.id}">
                            <td>${delivery.numero}</td>
                            <td>${delivery.statut}</td>
                            <td>${delivery.commandeClientId}</td>
                            <td>${delivery.entrepotId}</td>
                            <td>${delivery.dateLivraison}</td>
                            <td>
                                <a href="<c:url value='/sales/deliveries/${delivery.id}'/>" class="btn btn-sm btn-info">Voir</a>
                                <a href="<c:url value='/sales/deliveries/form?id=${delivery.id}'/>" class="btn btn-sm btn-warning">Modifier</a>
                                <form method="POST" action="<c:url value='/sales/deliveries/${delivery.id}/cancel'/>" style="display:inline;">
                                    <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
</body>
</html>
