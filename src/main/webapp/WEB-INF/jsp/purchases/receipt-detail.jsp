<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail reception - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Reception <c:out value="${receipt.numero}"/></h1>
                <a href="<c:url value='/purchases/receipts'/>" class="btn btn-secondary">Retour</a>
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

            <c:set var="orderStep" value="${empty order ? 'is-active' : 'is-done'}"/>
            <c:set var="receiptStep" value="is-active"/>
            <c:choose>
                <c:when test="${receipt.statut == 'VALIDEE'}">
                    <c:set var="receiptStep" value="is-done"/>
                </c:when>
                <c:when test="${receipt.statut == 'ANNULEE'}">
                    <c:set var="receiptStep" value="is-blocked"/>
                </c:when>
                <c:otherwise>
                    <c:set var="receiptStep" value="is-active"/>
                </c:otherwise>
            </c:choose>

            <c:set var="invoiceStep" value="${receipt.statut == 'VALIDEE' ? 'is-active' : 'is-blocked'}"/>
            <c:set var="stockStep" value="${receipt.statut == 'VALIDEE' ? 'is-done' : 'is-blocked'}"/>

            <div class="process-flow">
                <div class="process-step ${orderStep}">
                    <div class="step-title">Bon de commande</div>
                    <div class="step-note">${not empty order ? order.numero : 'En attente'}</div>
                </div>
                <div class="process-step ${receiptStep}">
                    <div class="step-title">Bon de reception</div>
                    <div class="step-note">${receipt.statut}</div>
                </div>
                <div class="process-step ${stockStep}">
                    <div class="step-title">Stock</div>
                    <div class="step-note">Mise a jour</div>
                </div>
                <div class="process-step ${invoiceStep}">
                    <div class="step-title">Facture achat</div>
                    <div class="step-note">${receipt.statut == 'VALIDEE' ? 'A generer' : 'Bloquee'}</div>
                </div>
            </div>

            <c:if test="${receipt.statut != 'VALIDEE'}">
                <div class="alert alert-info" style="margin-top: 12px;">
                    La facture et la mise a jour de stock s'activent apres validation de la reception.
                </div>
            </c:if>

            <div class="detail-container">
                <div class="detail-row">
                    <span class="detail-label">Statut :</span>
                    <span class="detail-value"><c:out value="${receipt.statut}"/></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date reception :</span>
                    <span class="detail-value"><c:out value="${receipt.dateReception}"/></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Commande :</span>
                    <span class="detail-value">
                        <c:choose>
                            <c:when test="${not empty order}">
                                <a href="<c:url value='/purchases/orders/${order.id}'/>"><c:out value="${order.numero}"/></a>
                            </c:when>
                            <c:otherwise><c:out value="${receipt.commandeId}"/></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Entrepot :</span>
                    <span class="detail-value">
                        <c:choose>
                            <c:when test="${not empty warehouse}">
                                <c:out value="${warehouse.code}"/> - <c:out value="${warehouse.nomDepot}"/>
                            </c:when>
                            <c:otherwise><c:out value="${receipt.entrepotId}"/></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <c:if test="${not empty receipt.notes}">
                    <div class="detail-row">
                        <span class="detail-label">Notes :</span>
                        <span class="detail-value"><c:out value="${receipt.notes}"/></span>
                    </div>
                </c:if>
            </div>

            <c:if test="${not empty receipt.lines}">
                <h3 style="margin-top: 16px;">Lignes</h3>
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Article</th>
                                <th>Quantite</th>
                                <th>Emplacement</th>
                                <th>Lot</th>
                                <th>Serie</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${receipt.lines}" var="l">
                                <tr>
                                    <td><c:out value="${l.article.code}"/> - <c:out value="${l.article.libelle}"/></td>
                                    <td><c:out value="${l.quantite}"/></td>
                                    <td><c:out value="${l.location}" default="-"/></td>
                                    <td><c:out value="${l.batchNumber}" default="-"/></td>
                                    <td><c:out value="${l.serialNumber}" default="-"/></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>

            <div class="form-actions" style="margin-top: 16px;">
                <c:if test="${receipt.statut == 'EN_COURS'}">
                    <form method="POST" action="<c:url value='/purchases/receipts/${receipt.id}/validate'/>" style="display:inline;">
                        <button class="btn btn-primary" type="submit">Valider la reception</button>
                    </form>
                </c:if>

                <c:if test="${receipt.statut == 'VALIDEE'}">
                    <form method="POST" action="<c:url value='/purchases/receipts/${receipt.id}/invoice'/>" style="display:inline;">
                        <button class="btn btn-success" type="submit">Generer facture achat</button>
                    </form>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>
