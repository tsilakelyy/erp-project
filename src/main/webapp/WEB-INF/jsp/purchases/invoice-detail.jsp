<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail facture achat - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Facture achat <c:out value="${invoice.numero}"/></h1>
                <a href="<c:url value='/purchases/invoices'/>" class="btn btn-secondary">Retour</a>
                <a href="<c:url value='/invoices/${invoice.id}/pdf'/>" class="btn btn-primary">Exporter PDF</a>
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

            <div class="process-flow">
                <div class="process-step is-done">
                    <div class="step-title">Bon de commande</div>
                    <div class="step-note">Validee</div>
                </div>
                <div class="process-step is-done">
                    <div class="step-title">Bon de reception</div>
                    <div class="step-note">Validee</div>
                </div>
                <div class="process-step is-done">
                    <div class="step-title">Stock</div>
                    <div class="step-note">Mise a jour</div>
                </div>
                <div class="process-step is-done">
                    <div class="step-title">Facture achat</div>
                    <div class="step-note"><c:out value="${invoice.statut}"/></div>
                </div>
            </div>

            <div class="detail-container">
                <div class="detail-row">
                    <span class="detail-label">Statut :</span>
                    <span class="detail-value"><c:out value="${invoice.statut}"/></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Fournisseur :</span>
                    <span class="detail-value">
                        <c:choose>
                            <c:when test="${not empty supplier}">
                                <c:out value="${supplier.nomEntreprise}"/>
                            </c:when>
                            <c:otherwise><c:out value="${invoice.tiersId}"/></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date facture :</span>
                    <span class="detail-value"><c:out value="${invoice.dateFacture}"/></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Montant HT :</span>
                    <span class="detail-value">Ar <c:out value="${invoice.montantHt}"/></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">TVA :</span>
                    <span class="detail-value">Ar <c:out value="${invoice.montantTva}"/></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Total TTC :</span>
                    <span class="detail-value">Ar <c:out value="${invoice.montantTtc}"/></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Taux TVA :</span>
                    <span class="detail-value"><c:out value="${invoice.tauxTva}"/></span>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
