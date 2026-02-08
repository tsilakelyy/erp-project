<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Stock entrepot - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Stock - ${warehouse.nomDepot}</h1>
                <a href="<c:url value='/stocks'/>" class="btn btn-secondary">Retour</a>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Articles</div>
                    <div class="kpi-value">${stocks.size()}</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-label">Valeur totale</div>
                    <div class="kpi-value">Ar ${totalValue}</div>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Article</th>
                            <th>Quantite actuelle</th>
                            <th>Reserve</th>
                            <th>Disponible</th>
                            <th>Valeur</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${stocks}" var="stock">
                            <tr>
                                <td>${stock.article.code} - ${stock.article.libelle}</td>
                                <td>${stock.quantiteActuelle}</td>
                                <td>${stock.quantiteReservee}</td>
                                <td>${stock.quantiteDisponible}</td>
                                <td>Ar ${stock.valeurTotale}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
