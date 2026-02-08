<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Detail commande d'achat - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Commande ${order.numero}</span>
    </nav>

        <div class="container mt-4">
            <div class="row mb-3">
            <div class="col-md-8">
                <h4>Details de la commande</h4>
                <dl class="row">
                    <dt class="col-sm-3">Numero :</dt>
                    <dd class="col-sm-9">${order.numero}</dd>

                    <dt class="col-sm-3">Fournisseur :</dt>
                    <dd class="col-sm-9">${order.fournisseurId}</dd>

                    <dt class="col-sm-3">Statut :</dt>
                    <dd class="col-sm-9"><span class="badge bg-info">${order.statut}</span></dd>

                    <dt class="col-sm-3">Date :</dt>
                    <dd class="col-sm-9">${order.dateCommande}</dd>

                    <dt class="col-sm-3">Montant TTC :</dt>
                    <dd class="col-sm-9">Ar ${order.montantTtc}</dd>
                </dl>
            </div>
            <div class="col-md-4">
                <h4>Actions</h4>
                <c:if test="${order.statut == 'BROUILLON'}">
                    <form method="POST" action="<c:url value='/purchases/orders/${order.id}/submit'/>" style="display:inline;">
                        <button type="submit" class="btn btn-success">Soumettre</button>
                    </form>
                </c:if>
                <c:if test="${order.statut == 'EN_COURS'}">
                    <form method="POST" action="<c:url value='/purchases/orders/${order.id}/approve'/>" style="display:inline;">
                        <button type="submit" class="btn btn-success">Valider</button>
                    </form>
                </c:if>
                <c:if test="${order.statut == 'VALIDEE'}">
                    <a href="<c:url value='/purchases/receipts/new?orderId=${order.id}'/>" class="btn btn-primary">Creer bon de reception</a>
                </c:if>
            </div>
        </div>

        <c:set var="orderStep" value="is-active"/>
        <c:choose>
            <c:when test="${order.statut == 'VALIDEE' || order.statut == 'RECUE' || order.statut == 'FACTUREE'}">
                <c:set var="orderStep" value="is-done"/>
            </c:when>
            <c:when test="${order.statut == 'ANNULEE'}">
                <c:set var="orderStep" value="is-blocked"/>
            </c:when>
            <c:otherwise>
                <c:set var="orderStep" value="is-active"/>
            </c:otherwise>
        </c:choose>

        <c:set var="receiptStep" value="is-blocked"/>
        <c:choose>
            <c:when test="${order.statut == 'VALIDEE'}">
                <c:set var="receiptStep" value="is-active"/>
            </c:when>
            <c:when test="${order.statut == 'RECUE' || order.statut == 'FACTUREE'}">
                <c:set var="receiptStep" value="is-done"/>
            </c:when>
            <c:when test="${order.statut == 'ANNULEE'}">
                <c:set var="receiptStep" value="is-blocked"/>
            </c:when>
        </c:choose>

        <c:set var="invoiceStep" value="is-blocked"/>
        <c:choose>
            <c:when test="${order.statut == 'RECUE'}">
                <c:set var="invoiceStep" value="is-active"/>
            </c:when>
            <c:when test="${order.statut == 'FACTUREE'}">
                <c:set var="invoiceStep" value="is-done"/>
            </c:when>
        </c:choose>

        <c:set var="stockStep" value="is-blocked"/>
        <c:if test="${order.statut == 'RECUE' || order.statut == 'FACTUREE'}">
            <c:set var="stockStep" value="is-done"/>
        </c:if>

        <div class="process-flow">
            <div class="process-step is-done">
                <div class="step-title">Demande d'achat</div>
                <div class="step-note">Validee</div>
            </div>
            <div class="process-step is-done">
                <div class="step-title">Proforma</div>
                <div class="step-note">Validee</div>
            </div>
            <div class="process-step ${orderStep}">
                <div class="step-title">Bon de commande</div>
                <div class="step-note">${order.statut}</div>
            </div>
            <div class="process-step ${receiptStep}">
                <div class="step-title">Bon de reception</div>
                <div class="step-note">${order.statut == 'VALIDEE' ? 'A creer' : 'En attente'}</div>
            </div>
            <div class="process-step ${stockStep}">
                <div class="step-title">Stock</div>
                <div class="step-note">Apres reception</div>
            </div>
            <div class="process-step ${invoiceStep}">
                <div class="step-title">Facture achat</div>
                <div class="step-note">${order.statut == 'RECUE' ? 'A generer' : 'En attente'}</div>
            </div>
        </div>

        <c:if test="${order.statut != 'VALIDEE' && order.statut != 'RECUE' && order.statut != 'FACTUREE'}">
            <div class="alert alert-info" style="margin-top: 12px;">
                Le bon de reception et la facture ne sont disponibles qu'apres validation de la commande.
            </div>
        </c:if>

        <h4>Lignes de commande</h4>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Article</th>
                    <th>Quantite</th>
                    <th>Prix unitaire</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${order.lines}" var="line">
                    <tr>
                        <td>${line.article.name}</td>
                        <td>${line.quantite}</td>
                        <td>Ar ${line.prixUnitaire}</td>
                        <td>Ar ${line.montant}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <a href="<c:url value='/purchases/orders'/>" class="btn btn-secondary">Retour</a>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </div>
</body>
</html>
