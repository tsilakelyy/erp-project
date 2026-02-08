<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion client - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <div class="client-login">
        <div class="login-flip-scene">
        <div class="client-login-card login-flip-card">
            <h1>Connexion client</h1>
            <p>Accedez a votre espace de suivi achats et factures.</p>

            <c:if test="${not empty param.error}">
                <div class="client-action-card" style="margin-bottom: 12px;">
                    <c:out value="${param.error}"/>
                </div>
            </c:if>
            <c:if test="${param.logout}">
                <div class="client-action-card" style="margin-bottom: 12px;">
                    Deconnexion reussie.
                </div>
            </c:if>

            <form method="POST" action="<c:url value='/login'/>">
                <input class="client-input" type="text" name="username" placeholder="Identifiant" required>
                <input class="client-input" type="password" name="password" placeholder="Mot de passe" required>
                <button class="client-button" type="submit">Se connecter</button>
            </form>

            <a class="client-link flip-link" href="<c:url value='/login'/>" data-flip-target="<c:url value='/login'/>">
                Connexion back office
            </a>
        </div>
        </div>
    </div>
    <script src="<c:url value='/assets/js/login-flip.js'/>"></script>
</body>
</html>
