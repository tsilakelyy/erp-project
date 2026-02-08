<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes demandes - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="requests"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero" style="grid-template-columns: 1fr;">
            <div>
                <h1>Mes demandes clients</h1>
                <p>Centralisez vos demandes de livraison, bons et devis en lien direct avec le back office.</p>
            </div>
        </section>

        <section class="client-section">
            <div class="client-section-header">
                <h2>Nouvelles demandes</h2>
                <div class="client-section-actions">
                    <a class="client-link" href="<c:url value='/client/requests/new?type=BON_REDUCTION'/>">Bon de reduction</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=BON_ACHAT'/>">Bon d'achat</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=LIVRAISON'/>">Demander livraison</a>
                </div>
            </div>
            <div class="client-actions">
                <a class="client-action-card" href="<c:url value='/client/requests/new?type=DEVIS'/>">
                    Demander un devis
                    <span>Lancer un proforma ou une estimation personnalisee</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/requests/new?type=PRODUIT'/>">
                    Demander un produit
                    <span>Besoin d'un article non disponible au catalogue</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/orders/new'/>">
                    Passer une commande
                    <span>Commander directement depuis votre espace client</span>
                </a>
            </div>
        </section>

        <section class="client-section">
            <h2>Suivi des demandes</h2>
            <c:if test="${param.success == '1'}">
                <div class="client-action-card" style="margin-bottom: 12px;">Demande envoyee avec succes.</div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="client-action-card" style="margin-bottom: 12px;">
                    <c:out value="${param.error}"/>
                </div>
            </c:if>

            <table class="client-table">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>Titre</th>
                        <th>Article</th>
                        <th>Quantite</th>
                        <th>Montant estime</th>
                        <th>Statut</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${requests}" var="req">
                        <c:set var="pillClass" value="client-pill" />
                        <c:if test="${req.statut == 'APPROUVEE' || req.statut == 'VALIDEE'}">
                            <c:set var="pillClass" value="client-pill success" />
                        </c:if>
                        <tr>
                            <td><c:out value="${req.requestType}"/></td>
                            <td><c:out value="${req.titre}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${req.articleId != null}">
                                        <c:out value="${articleNames[req.articleId]}"/>
                                    </c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${req.quantite}"/></td>
                            <td>Ar <c:out value="${req.montantEstime}"/></td>
                            <td><span class="${pillClass}"><c:out value="${req.statut}"/></span></td>
                            <td><c:out value="${req.dateCreation}"/></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty requests}">
                        <tr>
                            <td colspan="7">Aucune demande enregistree pour le moment.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </section>

        <div class="client-footer">Chaque demande est synchronisee avec votre equipe back office.</div>
    </main>
</body>
</html>
