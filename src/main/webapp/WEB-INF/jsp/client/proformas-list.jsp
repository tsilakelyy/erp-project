<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes proformas - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
 </head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="proformas"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero">
            <div>
                <h1>Mes proformas</h1>
                <p>Validez vos devis pour declencher la commande et la livraison.</p>
            </div>
        </section>

        <section class="client-section">
            <h2>Proformas en cours</h2>
            <table class="table">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Montant TTC</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${proformas}" var="pf">
                        <tr>
                            <td><c:out value="${pf.numero}"/></td>
                            <td><span class="badge badge-info"><c:out value="${pf.statut}"/></span></td>
                            <td>Ar <c:out value="${pf.montantTtc}" default="0"/></td>
                            <td><c:out value="${pf.dateProforma}" default="-" /></td>
                            <td>
                                <c:if test="${pf.statut == 'EN_ATTENTE'}">
                                    <form method="POST" action="<c:url value='/client/proformas/${pf.id}/approve'/>" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-primary">Valider</button>
                                    </form>
                                    <form method="POST" action="<c:url value='/client/proformas/${pf.id}/reject'/>" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-danger">Rejeter</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty proformas}">
                        <tr><td colspan="5">Aucune proforma disponible</td></tr>
                    </c:if>
                </tbody>
            </table>
        </section>
    </main>
</body>
</html>
