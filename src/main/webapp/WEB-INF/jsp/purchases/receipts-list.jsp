<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bons de reception - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Bons de reception</h1>
                <a href="<c:url value='/purchases/receipts/new'/>" class="btn btn-primary">+ Nouveau bon</a>
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
                            <th>Statut</th>
                            <th>Date</th>
                            <th>Commande</th>
                            <th>Entrepot</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${receipts}" var="r">
                            <tr data-receipt-id="${r.id}">
                                <td><strong><c:out value="${r.numero}"/></strong></td>
                                <td><span class="badge badge-info"><c:out value="${r.statut}"/></span></td>
                                <td><c:out value="${r.dateReception}"/></td>
                                <td><c:out value="${r.commandeId}"/></td>
                                <td><c:out value="${r.entrepotId}"/></td>
                                <td>
                                    <a href="<c:url value='/purchases/receipts/${r.id}'/>" class="btn btn-sm btn-info">Voir</a>
                                    <a href="<c:url value='/purchases/receipts/form?id=${r.id}'/>" class="btn btn-sm btn-warning">Modifier</a>
                                    <form method="POST" action="<c:url value='/purchases/receipts/${r.id}/cancel'/>" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty receipts}">
                            <tr><td colspan="6">Aucun bon de reception</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
</body>
</html>
