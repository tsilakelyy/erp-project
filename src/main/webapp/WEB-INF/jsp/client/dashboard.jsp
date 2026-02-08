<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Espace client - Tableau de bord</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="dashboard"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero">
            <div>
                <h1>
                    <c:choose>
                        <c:when test="${customer != null}">Bienvenue, <c:out value="${customer.nomEntreprise}"/></c:when>
                        <c:otherwise>Bienvenue dans votre espace client</c:otherwise>
                    </c:choose>
                </h1>
                <p>Suivez vos commandes, livraisons et factures en un seul endroit, avec une vue claire du cycle de vente.</p>
            </div>
            <div class="client-hero-card">
                <div style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.6px;">Total facture</div>
                <div style="font-size: 22px; font-weight: 700; margin-top: 6px;">Ar <c:out value="${invoicesTotal}"/></div>
                <div style="margin-top: 10px; font-size: 12px;">Mise a jour en temps reel</div>
            </div>
        </section>

        <section class="client-stats">
            <div class="client-stat">
                <div class="label">Commandes</div>
                <div class="value"><c:out value="${ordersCount}"/></div>
            </div>
            <div class="client-stat">
                <div class="label">Factures</div>
                <div class="value"><c:out value="${invoicesCount}"/></div>
            </div>
            <div class="client-stat">
                <div class="label">Total facture</div>
                <div class="value">Ar <c:out value="${invoicesTotal}"/></div>
            </div>
            <div class="client-stat">
                <div class="label">Compte client</div>
                <div class="value">
                    <c:choose>
                        <c:when test="${customer != null}"><c:out value="${customer.code}"/></c:when>
                        <c:otherwise>-</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </section>

        <section class="client-section">
            <h2>Actions rapides</h2>
            <div class="client-actions">
                <a class="client-action-card" href="<c:url value='/client/orders/new'/>">
                    Nouvelle commande
                    <span>Initier une nouvelle demande commerciale</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/products'/>">
                    Catalogue produits
                    <span>Parcourir les articles disponibles et demander un devis</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/orders'/>">
                    Mes commandes
                    <span>Consulter l'historique et les statuts</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/deliveries'/>">
                    Mes livraisons
                    <span>Suivre les expeditions en cours</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/invoices'/>">
                    Mes factures
                    <span>Telecharger et exporter les factures</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/proformas'/>">
                    Mes proformas
                    <span>Valider les devis et declencher les commandes</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/payments'/>">
                    Mes paiements
                    <span>Visualiser les reglements effectues</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/requests'/>">
                    Mes demandes
                    <span>Bons, livraisons et demandes produits</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/profile'/>">
                    Mon profil
                    <span>Mettre a jour vos informations</span>
                </a>
            </div>
        </section>

        <section class="client-section">
            <div class="client-section-header">
                <h2>Services client</h2>
                <div class="client-section-actions">
                    <a class="client-link" href="<c:url value='/client/requests/new?type=BON_REDUCTION'/>">Bon reduction</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=BON_ACHAT'/>">Bon achat</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=LIVRAISON'/>">Livraison</a>
                </div>
            </div>
            <div class="client-actions">
                <a class="client-action-card" href="<c:url value='/client/requests/new?type=DEVIS'/>">
                    Demander un devis
                    <span>Recevoir un proforma adapte a vos besoins</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/requests/new?type=PRODUIT'/>">
                    Demander un produit
                    <span>Signaler un article manquant ou specifique</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/orders/new'/>">
                    Commander maintenant
                    <span>Creer une commande avec validation back office</span>
                </a>
            </div>
        </section>

        <div class="client-footer">ERP Multisite - Espace client Madagascar</div>
    </main>
</body>
</html>
