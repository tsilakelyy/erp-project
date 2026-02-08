<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mouvements d'article - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Mouvements d'article</h1>
                <a href="<c:url value='/stocks'/>" class="btn btn-secondary">Retour</a>
            </div>

            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Quantite</th>
                            <th>ID entrepot</th>
                            <th>Reference</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${movements}" var="movement">
                            <tr>
                                <td>${movement.movementDate}</td>
                                <td>${movement.type}</td>
                                <td>${movement.quantity}</td>
                                <td>${movement.entrepotId}</td>
                                <td>${movement.reference}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
