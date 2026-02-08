<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Commandes d'achat - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Commandes d'achat</span>
    </nav>

    <div class="container mt-4">
        <div class="mb-3">
            <a href="<c:url value='/purchases/orders/new'/>" class="btn btn-primary">+ Nouvelle commande</a>
        </div>
        <c:if test="${param.success == '1'}">
            <div class="alert alert-success">Insertion reussie.</div>
        </c:if>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Numero</th>
                    <th>Fournisseur</th>
                    <th>Montant TTC</th>
                    <th>Statut</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${orders}" var="order">
                    <tr data-order-id="${order.id}">
                        <td>${order.numero}</td>
                        <td>${order.fournisseurId}</td>
                        <td>Ar ${order.montantTtc}</td>
                        <td><span class="badge bg-info">${order.statut}</span></td>
                        <td>${order.dateCommande}</td>
                        <td>
                            <a href="<c:url value='/purchases/orders/${order.id}'/>" class="btn btn-sm btn-info">Voir</a>
                            <a href="<c:url value='/purchases/orders/form?id=${order.id}'/>" class="btn btn-sm btn-warning">Modifier</a>
                            <form method="POST" action="<c:url value='/purchases/orders/${order.id}/cancel'/>" style="display:inline;">
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
