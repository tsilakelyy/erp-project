<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nouvelle proforma client - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Nouvelle proforma client</h1>
                <a href="<c:url value='/sales/proformas'/>" class="btn btn-secondary">Retour</a>
            </div>

            <c:if test="${not empty param.error}">
                <div class="global-alert global-alert--error">
                    <c:out value="${param.error}"/>
                </div>
            </c:if>

            <form method="POST" action="<c:url value='/sales/proformas'/>" class="form-container">
                <c:if test="${not empty proforma.requestId}">
                    <div class="form-group">
                        <label>Demande client</label>
                        <input type="text" class="form-control" value="${proforma.requestId}" disabled>
                        <input type="hidden" name="requestId" value="${proforma.requestId}">
                    </div>
                </c:if>

                <div class="form-group">
                    <label for="clientId">Client</label>
                    <select class="form-select" id="clientId" name="clientId" required>
                        <option value="">Selectionner</option>
                        <c:forEach items="${customers}" var="customer">
                            <option value="${customer.id}" ${proforma.clientId == customer.id ? 'selected' : ''}>
                                <c:out value="${customer.nomEntreprise}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="entrepotId">Entrepot</label>
                    <select class="form-select" id="entrepotId" name="entrepotId">
                        <option value="">Selectionner</option>
                        <c:forEach items="${warehouses}" var="wh">
                            <option value="${wh.id}" ${proforma.entrepotId == wh.id ? 'selected' : ''}>
                                <c:out value="${wh.code}"/> - <c:out value="${wh.nomDepot}"/> (<c:out value="${wh.ville}"/>)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="montantHt">Montant HT (Ar)</label>
                    <input type="number" class="form-control" id="montantHt" name="montantHt" step="0.01" value="${proforma.montantHt}">
                </div>

                <div class="form-group">
                    <label for="tauxTva">Taux TVA (%)</label>
                    <input type="number" class="form-control" id="tauxTva" name="tauxTva" step="0.01" value="20.00">
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Creer la proforma</button>
                    <a href="<c:url value='/sales/proformas'/>" class="btn btn-secondary">Annuler</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
