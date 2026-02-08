<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Factures d'achat - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Factures d'achat</h1>
            </div>

            <c:if test="${param.success == '1'}">
                <div class="alert alert-success">Operation reussie.</div>
            </c:if>

            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" id="pageError" data-error="<c:out value='${param.error}'/>"></div>
                <script>
                    (function() {
                        var el = document.getElementById('pageError');
                        if (!el) return;
                        var raw = el.getAttribute('data-error') || '';
                        try { el.textContent = decodeURIComponent(raw.replace(/\\+/g, ' ')); }
                        catch (e) { el.textContent = raw; }
                    })();
                </script>
            </c:if>

            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Numero</th>
                            <th>Fournisseur</th>
                            <th>Statut</th>
                            <th>Date</th>
                            <th>Total TTC</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${invoices}" var="inv">
                            <tr>
                                <td><strong><c:out value="${inv.numero}"/></strong></td>
                                <td><c:out value="${supplierNames[inv.tiersId]}" default="-"/></td>
                                <td><span class="badge badge-info"><c:out value="${inv.statut}"/></span></td>
                                <td><c:out value="${inv.dateFacture}"/></td>
                                <td>Ar <c:out value="${inv.montantTtc}"/></td>
                                <td>
                                    <a class="btn btn-sm btn-info" href="<c:url value='/purchases/invoices/${inv.id}'/>">Voir</a>
                                    <a class="btn btn-sm btn-secondary" href="<c:url value='/invoices/${inv.id}/pdf'/>">PDF</a>
                                    <form method="POST" action="<c:url value='/purchases/invoices/${inv.id}/cancel'/>" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty invoices}">
                            <tr><td colspan="6">Aucune facture d'achat</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
