<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proformas (Achats) - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Proformas (Achats)</h1>
                <a href="<c:url value='/purchases/proformas/new'/>" class="btn btn-primary">+ Nouvelle proforma</a>
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
                            <th>Importance</th>
                            <th>Validation</th>
                            <th>Montant TTC</th>
                            <th>Finance</th>
                            <th>Direction</th>
                            <th>Statut</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${proformas}" var="pf">
                            <tr>
                                <td><strong><c:out value="${pf.numero}"/></strong></td>
                                <td><c:out value="${supplierNames[pf.fournisseurId]}" default="-"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${pf.importance == 'ELEVEE'}">
                                            <span class="badge badge-danger">Elevee</span>
                                        </c:when>
                                        <c:when test="${pf.importance == 'FAIBLE'}">
                                            <span class="badge badge-secondary">Faible</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-info">Moyenne</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><span class="badge badge-secondary"><c:out value="${pf.validationMode}"/></span></td>
                                <td>Ar <c:out value="${pf.montantTtc}"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${pf.validationFinanceRequise}">
                                            <span class="badge ${pf.valideFinance ? 'badge-success' : 'badge-secondary'}">
                                                ${pf.valideFinance ? 'Validee' : 'En attente'}
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">Non requis</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${pf.validationDirectionRequise}">
                                            <span class="badge ${pf.valideDirection ? 'badge-success' : 'badge-secondary'}">
                                                ${pf.valideDirection ? 'Validee' : 'En attente'}
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">Non requis</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><span class="badge badge-info"><c:out value="${pf.statut}"/></span></td>
                                <td>
                                    <a class="btn btn-sm btn-info" href="<c:url value='/purchases/proformas/${pf.id}'/>">Voir</a>
                                    <a class="btn btn-sm btn-warning" href="<c:url value='/purchases/proformas/${pf.id}'/>">Modifier</a>
                                    <form method="POST" action="<c:url value='/purchases/proformas/${pf.id}/reject'/>" style="display:inline;">
                                        <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty proformas}">
                            <tr>
                                <td colspan="9">Aucune proforma</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
