<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bons clients - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Bons clients</h1>
                <a href="<c:url value='/sales/client-requests'/>" class="btn btn-secondary">Voir toutes les demandes</a>
            </div>

            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Client</th>
                        <th>Type</th>
                        <th>Titre</th>
                        <th>Montant (Ar)</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${requests}" var="req">
                        <tr>
                            <td><c:out value="${customerNames[req.customerId]}" default="-" /></td>
                            <td>
                                <c:choose>
                                    <c:when test="${req.requestType == 'BON_REDUCTION' || req.requestType == 'DISCOUNT_REQUEST'}">Bon reduction</c:when>
                                    <c:when test="${req.requestType == 'BON_ACHAT' || req.requestType == 'PURCHASE_VOUCHER'}">Bon d'achat</c:when>
                                    <c:otherwise><c:out value="${req.requestType}" /></c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${req.titre}" default="-" /></td>
                            <td>Ar <c:out value="${req.montantEstime}" default="-" /></td>
                            <td><span class="badge badge-info"><c:out value="${req.statut}" /></span></td>
                            <td><c:out value="${req.dateCreation}" default="-" /></td>
                            <td>
                                <c:if test="${req.statut != 'VALIDEE'}">
                                    <form method="POST" action="<c:url value='/sales/bons/${req.id}/approve'/>" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-success">Valider</button>
                                    </form>
                                </c:if>
                                <c:if test="${req.statut != 'REJETEE'}">
                                    <form method="POST" action="<c:url value='/sales/bons/${req.id}/reject'/>" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-danger">Rejeter</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty requests}">
                        <tr><td colspan="7">Aucun bon client</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
