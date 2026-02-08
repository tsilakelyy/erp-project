<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mon profil - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="profile"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero" style="grid-template-columns: 1fr;">
            <div>
                <h1>Mon profil</h1>
                <p>Retrouvez les informations du compte et les coordonnees de facturation.</p>
            </div>
        </section>

        <section class="client-section">
            <h2>Informations client</h2>
            <c:if test="${param.success == '1'}">
                <div class="client-action-card" style="margin-bottom: 12px;">
                    Profil mis a jour avec succes.
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="client-action-card" style="margin-bottom: 12px;">
                    <c:out value="${param.error}"/>
                </div>
            </c:if>
            <c:if test="${customer == null}">
                <div class="client-action-card">
                    Aucune information client liee a ce compte.
                </div>
            </c:if>

            <c:if test="${customer != null}">
                <div class="client-action-card">
                    <div><strong>Code :</strong> <c:out value="${customer.code}"/></div>
                    <div><strong>Entreprise :</strong> <c:out value="${customer.nomEntreprise}"/></div>
                    <div><strong>Email :</strong> <c:out value="${customer.email}"/></div>
                    <div><strong>Telephone :</strong> <c:out value="${customer.telephone}"/></div>
                    <div><strong>Adresse :</strong> <c:out value="${customer.adresse}"/></div>
                    <div><strong>Ville :</strong> <c:out value="${customer.ville}"/></div>
                </div>

                <div class="client-action-card" style="margin-top: 16px;">
                    <h3 style="margin-bottom: 12px;">Mettre a jour mes coordonnees</h3>
                    <form method="POST" action="<c:url value='/client/profile'/>">
                        <label class="client-input-label" for="email">Email</label>
                        <input class="client-input" id="email" name="email" type="email" value="<c:out value='${customer.email}'/>" required>

                        <label class="client-input-label" for="telephone">Telephone</label>
                        <input class="client-input" id="telephone" name="telephone" type="text" value="<c:out value='${customer.telephone}'/>">

                        <label class="client-input-label" for="adresse">Adresse</label>
                        <input class="client-input" id="adresse" name="adresse" type="text" value="<c:out value='${customer.adresse}'/>">

                        <label class="client-input-label" for="ville">Ville</label>
                        <input class="client-input" id="ville" name="ville" type="text" value="<c:out value='${customer.ville}'/>">

                        <label class="client-input-label" for="codePostal">Code postal</label>
                        <input class="client-input" id="codePostal" name="codePostal" type="text" value="<c:out value='${customer.codePostal}'/>">

                        <label class="client-input-label" for="contactPrincipal">Contact principal</label>
                        <input class="client-input" id="contactPrincipal" name="contactPrincipal" type="text" value="<c:out value='${customer.contactPrincipal}'/>">

                        <button class="client-button" type="submit">Enregistrer</button>
                    </form>
                </div>
            </c:if>
        </section>

        <div class="client-footer">Pour toute mise a jour, contactez votre administrateur.</div>
    </main>
</body>
</html>
