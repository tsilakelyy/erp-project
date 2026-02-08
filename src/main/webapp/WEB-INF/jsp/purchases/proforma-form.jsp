<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nouvelle proforma - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Nouvelle proforma (achat)</h1>
                <a href="<c:url value='/purchases/proformas'/>" class="btn btn-secondary">Retour</a>
            </div>

            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" id="formError" data-error="<c:out value='${param.error}'/>"></div>
                <script>
                    (function() {
                        var el = document.getElementById('formError');
                        if (!el) return;
                        var raw = el.getAttribute('data-error') || '';
                        try { el.textContent = decodeURIComponent(raw.replace(/\\+/g, ' ')); }
                        catch (e) { el.textContent = raw; }
                    })();
                </script>
            </c:if>

            <form method="POST" action="<c:url value='/purchases/proformas'/>" class="form-container">
                <c:if test="${not empty proforma.demandeId}">
                    <div class="form-group">
                        <label>Demande d'achat liee</label>
                        <input type="text" class="form-control" value="${proforma.demandeId}" disabled>
                        <input type="hidden" name="demandeId" value="${proforma.demandeId}">
                    </div>
                </c:if>

                <div class="form-group">
                    <label for="fournisseurId">Fournisseur *</label>
                    <select id="fournisseurId" name="fournisseurId" class="form-control" required>
                        <option value="">Selectionner</option>
                        <c:forEach items="${suppliers}" var="s">
                            <option value="${s.id}"><c:out value="${s.nomEntreprise}"/></option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="entrepotId">Entrepot *</label>
                    <select id="entrepotId" name="entrepotId" class="form-control" required>
                        <option value="">Selectionner</option>
                        <c:forEach items="${warehouses}" var="wh">
                            <option value="${wh.id}">
                                <c:out value="${wh.code}"/> - <c:out value="${wh.nomDepot}"/> (<c:out value="${wh.ville}"/>)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="montantHt">Montant HT (Ar)</label>
                        <input type="number" id="montantHt" name="montantHt" class="form-control" step="0.01" required>
                    </div>
                    <div class="form-group">
                        <label for="tauxTva">TVA (%)</label>
                        <input type="number" id="tauxTva" name="tauxTva" class="form-control" step="0.01" value="20.00">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="importance">Importance</label>
                        <select id="importance" name="importance" class="form-control">
                            <option value="FAIBLE">Faible</option>
                            <option value="MOYENNE" selected>Moyenne</option>
                            <option value="ELEVEE">Elevee</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="validationMode">Validation</label>
                        <select id="validationMode" name="validationMode" class="form-control">
                            <option value="AUTO" selected>Auto (selon montant/importance)</option>
                            <option value="FINANCE">Finance uniquement</option>
                            <option value="DIRECTION">Direction uniquement</option>
                            <option value="FINANCE_DIRECTION">Finance + Direction</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="dateValidite">Date de validite</label>
                    <input type="datetime-local" id="dateValidite" name="dateValidite" class="form-control">
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Creer</button>
                    <a href="<c:url value='/purchases/proformas'/>" class="btn btn-secondary">Annuler</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
