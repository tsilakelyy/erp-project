<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Demandes clients - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Demandes clients</h1>
                <a href="<c:url value='/reports/validations'/>" class="btn btn-secondary">Suivi validations</a>
            </div>

            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Client</th>
                        <th>Type</th>
                        <th>Titre</th>
                        <th>Article</th>
                        <th>Quantite</th>
                        <th>Montant estime</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${requests}" var="req">
                        <tr>
                            <td><c:out value="${customerNames[req.customerId]}" default="-" /></td>
                            <td><c:out value="${req.requestType}" /></td>
                            <td><c:out value="${req.titre}" default="-" /></td>
                            <td><c:out value="${articleNames[req.articleId]}" default="-" /></td>
                            <td><c:out value="${req.quantite}" default="-" /></td>
                            <td>Ar <c:out value="${req.montantEstime}" default="-" /></td>
                            <td><span class="badge badge-info"><c:out value="${req.statut}" /></span></td>
                            <td>
                                <c:if test="${req.requestType == 'DEVIS' || req.requestType == 'COMMANDE' || req.requestType == 'ORDER_REQUEST'}">
                                    <form method="POST" action="<c:url value='/sales/client-requests/${req.id}/to-order'/>" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-primary">Creer proforma</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty requests}">
                        <tr><td colspan="8">Aucune demande client</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
