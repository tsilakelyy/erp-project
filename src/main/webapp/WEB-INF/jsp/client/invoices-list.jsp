<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes factures - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="invoices"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero" style="grid-template-columns: 1fr;">
            <div>
                <h1>Mes factures</h1>
                <p>Retrouvez vos factures et suivez les paiements en cours.</p>
            </div>
        </section>

        <section class="client-section">
            <div class="client-section-header">
                <h2>Facturation</h2>
                <div class="client-section-actions">
                    <a class="client-link" href="<c:url value='/client/payments'/>">Voir paiements</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=BON_REDUCTION'/>">Bon reduction</a>
                </div>
            </div>
            <table class="client-table">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Montant TTC</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${invoices}" var="inv">
                        <c:set var="pillClass" value="client-pill" />
                        <c:if test="${inv.statut == 'PAYEE'}">
                            <c:set var="pillClass" value="client-pill success" />
                        </c:if>
                        <tr>
                            <td><c:out value="${inv.numero}"/></td>
                            <td><span class="${pillClass}"><c:out value="${inv.statut}"/></span></td>
                            <td><c:out value="${inv.dateFacture}"/></td>
                            <td>Ar <c:out value="${inv.montantTtc}"/></td>
                            <td>
                                <a class="client-link" href="<c:url value='/invoices/${inv.id}/pdf'/>" target="_blank">PDF</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty invoices}">
                        <tr>
                            <td colspan="5">Aucune facture disponible.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <div class="client-footer">Export PDF disponible depuis vos factures.</div>
    </main>
</body>
</html>
