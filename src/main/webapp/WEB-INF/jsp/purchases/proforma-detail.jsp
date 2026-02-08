<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail proforma - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Proforma <c:out value="${proforma.numero}"/></h1>
                <a href="<c:url value='/purchases/proformas'/>" class="btn btn-secondary">Retour</a>
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

            <c:set var="financeStep" value="is-done"/>
            <c:if test="${proforma.validationFinanceRequise}">
                <c:choose>
                    <c:when test="${proforma.valideFinance}">
                        <c:set var="financeStep" value="is-done"/>
                    </c:when>
                    <c:when test="${proforma.statut == 'REJETEE'}">
                        <c:set var="financeStep" value="is-blocked"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="financeStep" value="is-active"/>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <c:set var="directionStep" value="is-done"/>
            <c:if test="${proforma.validationDirectionRequise}">
                <c:choose>
                    <c:when test="${proforma.valideDirection}">
                        <c:set var="directionStep" value="is-done"/>
                    </c:when>
                    <c:when test="${proforma.statut == 'REJETEE'}">
                        <c:set var="directionStep" value="is-blocked"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="directionStep" value="is-active"/>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <c:set var="orderStep" value="is-blocked"/>
            <c:choose>
                <c:when test="${proforma.statut == 'TRANSFORMEE_BC'}">
                    <c:set var="orderStep" value="is-done"/>
                </c:when>
                <c:when test="${proforma.statut == 'VALIDEE'}">
                    <c:set var="orderStep" value="is-active"/>
                </c:when>
                <c:when test="${proforma.statut == 'REJETEE'}">
                    <c:set var="orderStep" value="is-blocked"/>
                </c:when>
            </c:choose>

            <c:set var="receiptStep" value="${proforma.statut == 'TRANSFORMEE_BC' ? 'is-active' : 'is-blocked'}"/>

            <div class="process-flow">
                <div class="process-step ${not empty proforma.demandeId ? 'is-done' : 'is-active'}">
                    <div class="step-title">Demande d'achat</div>
                    <div class="step-note">${not empty proforma.demandeId ? 'Liee' : 'Libre'}</div>
                </div>
                <div class="process-step ${proforma.statut == 'REJETEE' ? 'is-blocked' : 'is-done'}">
                    <div class="step-title">Proforma</div>
                    <div class="step-note">${proforma.statut}</div>
                </div>
                <div class="process-step ${financeStep}">
                    <div class="step-title">Validation Finance</div>
                    <div class="step-note">${proforma.validationFinanceRequise ? 'Requise' : 'Non requise'}</div>
                </div>
                <div class="process-step ${directionStep}">
                    <div class="step-title">Validation Direction</div>
                    <div class="step-note">${proforma.validationDirectionRequise ? 'Requise' : 'Non requise'}</div>
                </div>
                <div class="process-step ${orderStep}">
                    <div class="step-title">Bon de commande</div>
                    <div class="step-note">${proforma.statut == 'VALIDEE' ? 'A creer' : 'En attente'}</div>
                </div>
                <div class="process-step ${receiptStep}">
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

            <c:if test="${proforma.statut != 'VALIDEE' && proforma.statut != 'TRANSFORMEE_BC' && proforma.statut != 'REJETEE'}">
                <div class="alert alert-info">
                    Le bon de commande reste bloque tant que la proforma n'est pas validee par les acteurs requis.
                </div>
            </c:if>

            <div class="card">
                <div class="card-body">
                    <p><strong>Statut:</strong> <c:out value="${proforma.statut}"/></p>
                    <p><strong>Fournisseur:</strong>
                        <c:choose>
                            <c:when test="${not empty supplier}">
                                <c:out value="${supplier.nomEntreprise}"/>
                            </c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </p>
                    <p><strong>Entrepot:</strong>
                        <c:choose>
                            <c:when test="${not empty warehouse}">
                                <c:out value="${warehouse.code}"/> - <c:out value="${warehouse.nomDepot}"/>
                            </c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </p>
                    <p><strong>Montant:</strong> Ar <c:out value="${proforma.montantTtc}"/></p>
                    <p><strong>TVA:</strong> <c:out value="${proforma.tauxTva}"/>%</p>

                    <hr/>
                    <p><strong>Validation Finance requise:</strong> ${proforma.validationFinanceRequise ? 'Oui' : 'Non'}</p>
                    <p><strong>Validation Direction requise:</strong> ${proforma.validationDirectionRequise ? 'Oui' : 'Non'}</p>
                    <p><strong>Finance:</strong> ${proforma.valideFinance ? 'Validee' : 'En attente'}</p>
                    <p><strong>Direction:</strong> ${proforma.valideDirection ? 'Validee' : 'En attente'}</p>

                    <c:if test="${not empty proforma.motifRejet}">
                        <div class="alert alert-warning">
                            <strong>Motif de rejet:</strong> <c:out value="${proforma.motifRejet}"/>
                        </div>
                    </c:if>
                </div>
            </div>

            <div class="form-actions" style="margin-top: 16px;">
                <c:if test="${isFinance && proforma.validationFinanceRequise && !proforma.valideFinance && proforma.statut != 'REJETEE'}">
                    <form method="POST" action="<c:url value='/purchases/proformas/${proforma.id}/validate-finance'/>" style="display:inline;">
                        <button class="btn btn-primary" type="submit">Valider (Finance)</button>
                    </form>
                </c:if>

                <c:if test="${isDirection && proforma.validationDirectionRequise && !proforma.valideDirection && proforma.statut != 'REJETEE'}">
                    <form method="POST" action="<c:url value='/purchases/proformas/${proforma.id}/validate-direction'/>" style="display:inline;">
                        <button class="btn btn-primary" type="submit">Valider (Direction)</button>
                    </form>
                </c:if>

                <c:if test="${proforma.statut != 'REJETEE'}">
                    <form method="POST" action="<c:url value='/purchases/proformas/${proforma.id}/reject'/>" style="display:inline;">
                        <input type="text" name="motif" class="form-control" placeholder="Motif de rejet" style="width: 260px; display:inline-block; vertical-align: middle;">
                        <button class="btn btn-danger" type="submit">Rejeter</button>
                    </form>
                </c:if>

                <c:if test="${proforma.statut == 'VALIDEE'}">
                    <form method="POST" action="<c:url value='/purchases/proformas/${proforma.id}/to-order'/>" style="display:inline;">
                        <button class="btn btn-success" type="submit">Creer le bon de commande</button>
                    </form>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>
