<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Detail client - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - ${customer.name}</span>
    </nav>

    <div class="container mt-4">
        <div class="row mb-3">
            <div class="col-md-8">
                <h4>Details du client</h4>
                <dl class="row">
                    <dt class="col-sm-3">Code :</dt>
                    <dd class="col-sm-9">${customer.code}</dd>

                    <dt class="col-sm-3">Nom :</dt>
                    <dd class="col-sm-9">${customer.name}</dd>

                    <dt class="col-sm-3">Email :</dt>
                    <dd class="col-sm-9">${customer.email}</dd>

                    <dt class="col-sm-3">Telephone :</dt>
                    <dd class="col-sm-9">${customer.phone}</dd>

                    <dt class="col-sm-3">Adresse :</dt>
                    <dd class="col-sm-9">${customer.address}</dd>

                    <dt class="col-sm-3">Ville :</dt>
                    <dd class="col-sm-9">${customer.city}</dd>

                    <dt class="col-sm-3">Delai de paiement :</dt>
                    <dd class="col-sm-9">${customer.paymentTermsDays} jours</dd>
                </dl>
            </div>
        </div>

        <a href="<c:url value='/customers'/>" class="btn btn-secondary">Retour</a>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </div>
</body>
</html>
