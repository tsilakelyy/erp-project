<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Demande de devis - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="orders"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero" style="grid-template-columns: 1fr;">
            <div>
                <h1>Demande de devis</h1>
                <p>Soumettez votre demande pour recevoir une proforma. La commande demarre apres validation du devis.</p>
            </div>
        </section>

        <section class="client-section">
            <h2>Informations de devis</h2>

            <c:if test="${not empty param.error}">
                <div class="client-action-card" style="margin-bottom: 12px;">
                    <c:out value="${param.error}"/>
                </div>
            </c:if>
            <c:if test="${param.success == '1'}">
                <div class="client-action-card" style="margin-bottom: 12px;">
                    Commande enregistree avec succes.
                </div>
            </c:if>

            <form method="POST" action="<c:url value='/client/orders'/>">
                <label for="entrepotId" class="client-input-label">Entrepot</label>
                <select class="client-input" id="entrepotId" name="entrepotId" required>
                    <option value="">Selectionner un entrepot</option>
                    <c:forEach items="${warehouses}" var="wh">
                        <option value="${wh.id}">
                            <c:out value="${wh.code}"/> - <c:out value="${wh.nomDepot}"/> (<c:out value="${wh.ville}"/>)
                        </option>
                    </c:forEach>
                </select>

                <label for="montantHt" class="client-input-label">Montant HT (Ar)</label>
                <input class="client-input" id="montantHt" name="montantHt" type="number" step="0.01" required>

                <label for="tauxTva" class="client-input-label">Taux TVA (%)</label>
                <input class="client-input" id="tauxTva" name="tauxTva" type="number" step="0.01" value="20.00">

                <button class="client-button" type="submit">Envoyer la demande</button>
                <a class="client-link" href="<c:url value='/client/requests'/>">Retour aux demandes</a>
            </form>
        </section>

        <div class="client-footer">Les devis sont prepares par votre equipe commerciale.</div>
    </main>
</body>
</html>
