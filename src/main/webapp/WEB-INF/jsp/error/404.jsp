<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ERP - Erreur 404</title>
<style>
        .error-container {
            margin-top: 100px;
            text-align: center;
            padding: 50px;
        }
        .error-code {
            font-size: 72px;
            font-weight: bold;
            color: #dc3545;
        }
        .error-message {
            font-size: 24px;
            margin-bottom: 20px;
        }
        .error-description {
            font-size: 16px;
            color: #666;
            margin-bottom: 30px;
        }
    </style>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <div class="error-container">
        <div class="error-code">404</div>
        <div class="error-message">Page introuvable</div>
        <div class="error-description">La page demandee n'existe pas.</div>
        <a href="<c:url value='/dashboard'/>" class="btn btn-primary">Retour au tableau de bord</a>
    </div>
    </div>
</body>
</html>




