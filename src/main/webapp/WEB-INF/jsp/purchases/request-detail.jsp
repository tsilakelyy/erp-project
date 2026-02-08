<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail demande d'achat - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Demande ${request.numero}</h1>
                <a href="<c:url value='/purchases/requests'/>" class="btn btn-secondary">Retour</a>
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
                        try {
                            el.textContent = decodeURIComponent(raw.replace(/\\+/g, ' '));
                        } catch (e) {
                            el.textContent = raw;
                        }
                    })();
                </script>
            </c:if>

            <c:set var="financeStep" value="is-done"/>
            <c:if test="${request.validationFinanceRequise}">
                <c:choose>
                    <c:when test="${request.valideFinance}">
                        <c:set var="financeStep" value="is-done"/>
                    </c:when>
                    <c:when test="${request.statut == 'REJETEE'}">
                        <c:set var="financeStep" value="is-blocked"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="financeStep" value="is-active"/>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <c:set var="directionStep" value="is-done"/>
            <c:if test="${request.validationDirectionRequise}">
                <c:choose>
                    <c:when test="${request.valideDirection}">
                        <c:set var="directionStep" value="is-done"/>
                    </c:when>
                    <c:when test="${request.statut == 'REJETEE'}">
                        <c:set var="directionStep" value="is-blocked"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="directionStep" value="is-active"/>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <c:set var="proformaStep" value="is-blocked"/>
            <c:choose>
                <c:when test="${request.statut == 'APPROUVEE'}">
                    <c:set var="proformaStep" value="is-active"/>
                </c:when>
                <c:when test="${request.statut == 'REJETEE'}">
                    <c:set var="proformaStep" value="is-blocked"/>
                </c:when>
                <c:otherwise>
                    <c:set var="proformaStep" value="is-blocked"/>
                </c:otherwise>
            </c:choose>

            <div class="process-flow">
                <div class="process-step is-done">
                    <div class="step-title">Demande d'achat</div>
                    <div class="step-note">Creee</div>
                </div>
                <div class="process-step ${financeStep}">
                    <div class="step-title">Validation Finance</div>
                    <div class="step-note">${request.validationFinanceRequise ? 'Requise' : 'Non requise'}</div>
                </div>
                <div class="process-step ${directionStep}">
                    <div class="step-title">Validation Direction</div>
                    <div class="step-note">${request.validationDirectionRequise ? 'Requise' : 'Non requise'}</div>
                </div>
                <div class="process-step ${proformaStep}">
                    <div class="step-title">Proforma</div>
                    <div class="step-note">${request.statut == 'APPROUVEE' ? 'A creer' : 'Bloque'}</div>
                </div>
                <div class="process-step is-blocked">
                    <div class="step-title">Bon de commande</div>
                    <div class="step-note">Apres proforma</div>
                </div>
                <div class="process-step is-blocked">
                    <div class="step-title">Bon de reception</div>
                    <div class="step-note">Apres commande</div>
                </div>
                <div class="process-step is-blocked">
                    <div class="step-title">Stock</div>
                    <div class="step-note">Entree en stock</div>
                </div>
                <div class="process-step is-blocked">
                    <div class="step-title">Facture</div>
                    <div class="step-note">Generation finale</div>
                </div>
            </div>

            <c:if test="${request.statut != 'APPROUVEE' && request.statut != 'REJETEE'}">
                <div class="alert alert-info">
                    La proforma est bloquee tant que les validations requises (Finance/Direction) ne sont pas completees.
                </div>
            </c:if>

            <div class="detail-container">
                <div class="detail-row">
                    <span class="detail-label">Statut :</span>
                    <span class="detail-value">${request.statut}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Creation :</span>
                    <span class="detail-value">${request.dateCreation}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Montant estime :</span>
                    <span class="detail-value">Ar ${request.montantEstime}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Entrepot ID :</span>
                    <span class="detail-value">${request.entrepotId}</span>
                </div>

                <div class="detail-row">
                    <span class="detail-label">Importance :</span>
                    <span class="detail-value">${empty request.importance ? '-' : request.importance}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Validation Finance requise :</span>
                    <span class="detail-value">${request.validationFinanceRequise ? 'Oui' : 'Non'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Validation Direction requise :</span>
                    <span class="detail-value">${request.validationDirectionRequise ? 'Oui' : 'Non'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Finance :</span>
                    <span class="detail-value">${request.valideFinance ? 'Validee' : 'En attente'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Direction :</span>
                    <span class="detail-value">${request.valideDirection ? 'Validee' : 'En attente'}</span>
                </div>

                <c:if test="${not empty request.motifRejet}">
                    <div class="alert alert-warning">
                        <strong>Motif de rejet :</strong> <c:out value="${request.motifRejet}"/>
                    </div>
                </c:if>
            </div>

            <div class="form-actions" style="margin-top: 16px;">
                <c:if test="${isFinance && request.validationFinanceRequise && !request.valideFinance && request.statut != 'REJETEE'}">
                    <form method="POST" action="<c:url value='/purchases/requests/${request.id}/validate-finance'/>" style="display:inline;">
                        <button class="btn btn-primary" type="submit">Valider (Finance)</button>
                    </form>
                </c:if>

                <c:if test="${isDirection && request.validationDirectionRequise && !request.valideDirection && request.statut != 'REJETEE'}">
                    <form method="POST" action="<c:url value='/purchases/requests/${request.id}/validate-direction'/>" style="display:inline;">
                        <button class="btn btn-primary" type="submit">Valider (Direction)</button>
                    </form>
                </c:if>

                <c:if test="${request.statut != 'REJETEE'}">
                    <form method="POST" action="<c:url value='/purchases/requests/${request.id}/reject'/>" style="display:inline;">
                        <input type="text" name="motif" class="form-control" placeholder="Motif de rejet" style="width: 260px; display:inline-block; vertical-align: middle;">
                        <button class="btn btn-danger" type="submit">Rejeter</button>
                    </form>
                </c:if>

                <c:if test="${request.statut == 'APPROUVEE'}">
                    <a class="btn btn-success" href="<c:url value='/purchases/proformas/new?requestId=${request.id}'/>">Creer une proforma</a>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>
