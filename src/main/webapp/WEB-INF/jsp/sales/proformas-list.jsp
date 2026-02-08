<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proformas clients - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Proformas clients</h1>
                <a href="<c:url value='/sales/proformas/new'/>" class="btn btn-primary">+ Nouvelle proforma</a>
            </div>
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" id="formError" data-error="<c:out value='${param.error}'/>"></div>
                <script>
                    (function() {
                        var el = document.getElementById('formError');
                        if (!el) return;
                        var raw = el.getAttribute('data-error') || '';
                        try {
                            el.textContent = decodeURIComponent(raw.replace(/\\+/g, ' '));
                        } catch (e) {
                            el.textContent = raw;
                        }
                    })();
                </script>
            </c:if>

            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Client</th>
                        <th>Montant TTC</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${proformas}" var="pf">
                        <tr>
                            <td><c:out value="${pf.numero}"/></td>
                            <td><c:out value="${customerNames[pf.clientId]}" default="-" /></td>
                            <td>Ar <c:out value="${pf.montantTtc}" default="0"/></td>
                            <td><span class="badge bg-info"><c:out value="${pf.statut}"/></span></td>
                            <td><c:out value="${pf.dateProforma}" default="-" /></td>
                            <td>
                                <a href="<c:url value='/sales/proformas/${pf.id}'/>" class="btn btn-sm btn-info">Voir</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty proformas}">
                        <tr><td colspan="6">Aucune proforma client</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
