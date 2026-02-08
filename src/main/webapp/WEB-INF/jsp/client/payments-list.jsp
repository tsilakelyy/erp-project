<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes paiements - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="payments"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero" style="grid-template-columns: 1fr;">
            <div>
                <h1>Historique des paiements</h1>
                <p>Suivez vos paiements, les moyens utilises et le rapprochement avec vos factures.</p>
            </div>
        </section>

        <section class="client-section">
            <div class="client-section-header">
                <h2>Paiements enregistres</h2>
                <div class="client-section-actions">
                    <a class="client-link" href="<c:url value='/client/invoices'/>">Voir mes factures</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=BON_ACHAT'/>">Demander un bon</a>
                </div>
            </div>

            <table class="client-table">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Date paiement</th>
                        <th>Montant</th>
                        <th>Moyen</th>
                        <th>Facture</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${payments}" var="payment">
                        <c:set var="pillClass" value="client-pill" />
                        <c:if test="${payment.statut == 'PAYE' || payment.statut == 'PAYEE'}">
                            <c:set var="pillClass" value="client-pill success" />
                        </c:if>
                        <tr>
                            <td><c:out value="${payment.numero}"/></td>
                            <td><span class="${pillClass}"><c:out value="${payment.statut}"/></span></td>
                            <td><c:out value="${payment.datePaiement}"/></td>
                            <td>Ar <c:out value="${payment.montant}"/></td>
                            <td><c:out value="${payment.moyenPaiement}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${invoicesById[payment.factureId] != null}">
                                        <c:out value="${invoicesById[payment.factureId].numero}"/>
                                        <a class="client-link" href="<c:url value='/invoices/${payment.factureId}/pdf'/>" target="_blank">PDF</a>
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty payments}">
                        <tr>
                            <td colspan="6">Aucun paiement enregistre.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <div class="client-footer">Vos paiements sont synchronises avec le back office finance.</div>
    </main>
</body>
</html>
