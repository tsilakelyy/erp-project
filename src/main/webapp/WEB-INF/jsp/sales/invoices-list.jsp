<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Factures - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Factures</h1>
                <a href="<c:url value='/sales/orders'/>" class="btn btn-secondary">Commandes</a>
            </div>

            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Type</th>
                        <th>Montant</th>
                        <th>Date facture</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${invoices}" var="invoice">
                        <tr data-invoice-id="${invoice.id}">
                            <td>${invoice.numero}</td>
                            <td>${invoice.statut}</td>
                            <td>${invoice.typeFacture}</td>
                            <td>Ar ${invoice.montantTtc}</td>
                            <td>${invoice.dateFacture}</td>
                            <td>
                                <a href="<c:url value='/sales/invoices/${invoice.id}'/>" class="btn btn-sm btn-info">Voir</a>
                                <a href="<c:url value='/invoices/${invoice.id}/pdf'/>" class="btn btn-sm btn-secondary">PDF</a>
                                <form method="POST" action="<c:url value='/sales/invoices/${invoice.id}/cancel'/>" style="display:inline;">
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
