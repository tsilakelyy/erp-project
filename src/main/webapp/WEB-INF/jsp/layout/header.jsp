<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="isAdminRole" value="false" />
<c:set var="isClientRole" value="false" />
<c:if test="${not empty sessionScope.user && not empty sessionScope.user.roles}">
    <c:forEach items="${sessionScope.user.roles}" var="role">
        <c:if test="${role.code == 'ADMIN'}">
            <c:set var="isAdminRole" value="true" />
        </c:if>
        <c:if test="${role.code == 'CLIENT'}">
            <c:set var="isClientRole" value="true" />
        </c:if>
    </c:forEach>
</c:if>

<header class="header">
    <div class="header-brand">
        <c:url var="dashboardUrl" value="/dashboard"/>
        <a href="${dashboardUrl}" style="color: white; text-decoration: none;">ERP Multisite</a>
    </div>
    <nav class="header-nav">
        <a href="#" onclick="toggleLanguage()">FR</a>
        <a href="#" onclick="logout()">Deconnexion</a>
    </nav>
</header>

<c:set var="pagePath" value="${pageContext.request.requestURI}" />
<c:set var="pageKey" value="core" />
<c:set var="pageTitle" value="ERP Multisite" />
<c:set var="pageTagline" value="Pilotage centralise des operations" />

<c:choose>
    <c:when test="${fn:contains(pagePath, '/dashboard/achats')}">
        <c:set var="pageKey" value="dashboard-achat" />
        <c:set var="pageTitle" value="Tableau de bord Achats" />
        <c:set var="pageTagline" value="Suivi des demandes, proformas et commandes" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/dashboard/ventes')}">
        <c:set var="pageKey" value="dashboard-vente" />
        <c:set var="pageTitle" value="Tableau de bord Ventes" />
        <c:set var="pageTagline" value="Commandes, livraisons et facturation" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/dashboard/finance')}">
        <c:set var="pageKey" value="dashboard-finance" />
        <c:set var="pageTitle" value="Tableau de bord Finance" />
        <c:set var="pageTagline" value="Tresorerie, marges et factures" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/dashboard/direction')}">
        <c:set var="pageKey" value="dashboard-direction" />
        <c:set var="pageTitle" value="Tableau de bord Direction" />
        <c:set var="pageTagline" value="Vue executif et performance globale" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/dashboard/stocks')}">
        <c:set var="pageKey" value="dashboard-stock" />
        <c:set var="pageTitle" value="Tableau de bord Stock" />
        <c:set var="pageTagline" value="Etat des niveaux et alertes" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/dashboard')}">
        <c:set var="pageKey" value="dashboard" />
        <c:set var="pageTitle" value="Tableau de bord" />
        <c:set var="pageTagline" value="Indicateurs clefs en temps reel" />
    </c:when>

    <c:when test="${fn:contains(pagePath, '/purchases/requests')}">
        <c:set var="pageKey" value="purchase-requests" />
        <c:set var="pageTitle" value="Demandes d'achat" />
        <c:set var="pageTagline" value="Expression des besoins magasins" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/purchases/proformas')}">
        <c:set var="pageKey" value="purchase-proformas" />
        <c:set var="pageTitle" value="Proformas fournisseurs" />
        <c:set var="pageTagline" value="Validation finance/direction" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/purchases/orders')}">
        <c:set var="pageKey" value="purchase-orders" />
        <c:set var="pageTitle" value="Bons de commande" />
        <c:set var="pageTagline" value="Engagement achats" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/purchases/receipts')}">
        <c:set var="pageKey" value="purchase-receipts" />
        <c:set var="pageTitle" value="Bons de reception" />
        <c:set var="pageTagline" value="Controle et entree en stock" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/purchases/invoices')}">
        <c:set var="pageKey" value="purchase-invoices" />
        <c:set var="pageTitle" value="Factures d'achat" />
        <c:set var="pageTagline" value="Controle comptable et paiements" />
    </c:when>

    <c:when test="${fn:contains(pagePath, '/sales/orders')}">
        <c:set var="pageKey" value="sales-orders" />
        <c:set var="pageTitle" value="Commandes clients" />
        <c:set var="pageTagline" value="Cycle de vente complet" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/sales/bons')}">
        <c:set var="pageKey" value="sales-bons" />
        <c:set var="pageTitle" value="Bons clients" />
        <c:set var="pageTagline" value="Bons d'achat et reductions" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/sales/proformas')}">
        <c:set var="pageKey" value="sales-proformas" />
        <c:set var="pageTitle" value="Proformas clients" />
        <c:set var="pageTagline" value="Devis commerciaux et validation client" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/sales/deliveries')}">
        <c:set var="pageKey" value="sales-deliveries" />
        <c:set var="pageTitle" value="Livraisons" />
        <c:set var="pageTagline" value="Preparation et expedition" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/sales/invoices')}">
        <c:set var="pageKey" value="sales-invoices" />
        <c:set var="pageTitle" value="Factures clients" />
        <c:set var="pageTagline" value="Emission et suivi" />
    </c:when>

    <c:when test="${fn:contains(pagePath, '/inventories')}">
        <c:set var="pageKey" value="inventories" />
        <c:set var="pageTitle" value="Inventaires" />
        <c:set var="pageTagline" value="Controle physique des stocks" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/stocks')}">
        <c:set var="pageKey" value="stocks" />
        <c:set var="pageTitle" value="Niveaux de stock" />
        <c:set var="pageTagline" value="Quantites, seuils et alertes" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/warehouses')}">
        <c:set var="pageKey" value="warehouses" />
        <c:set var="pageTitle" value="Entrepots" />
        <c:set var="pageTagline" value="Capacite et localisation" />
    </c:when>

    <c:when test="${fn:contains(pagePath, '/reports')}">
        <c:set var="pageKey" value="reports" />
        <c:set var="pageTitle" value="Rapports & analyses" />
        <c:set var="pageTagline" value="Tableaux analytiques et exports" />
    </c:when>

    <c:when test="${fn:contains(pagePath, '/articles')}">
        <c:set var="pageKey" value="articles" />
        <c:set var="pageTitle" value="Articles" />
        <c:set var="pageTagline" value="Catalogues et references" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/suppliers')}">
        <c:set var="pageKey" value="suppliers" />
        <c:set var="pageTitle" value="Fournisseurs" />
        <c:set var="pageTagline" value="Partenaires et conditions" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/customers')}">
        <c:set var="pageKey" value="customers" />
        <c:set var="pageTitle" value="Clients" />
        <c:set var="pageTagline" value="Comptes et historique" />
    </c:when>

    <c:when test="${fn:contains(pagePath, '/admin')}">
        <c:set var="pageKey" value="admin" />
        <c:set var="pageTitle" value="Administration" />
        <c:set var="pageTagline" value="Utilisateurs, roles et parametres" />
    </c:when>
    <c:when test="${fn:contains(pagePath, '/client')}">
        <c:set var="pageKey" value="client" />
        <c:set var="pageTitle" value="Espace client" />
        <c:set var="pageTagline" value="Suivi commandes et factures" />
    </c:when>
</c:choose>

<div class="page-identity page-identity--${pageKey}">
    <div class="page-identity__title">${pageTitle}</div>
    <div class="page-identity__tagline">${pageTagline}</div>
</div>

<c:if test="${not empty param.error}">
    <div class="global-alert global-alert--error">
        <c:out value="${param.error}"/>
    </div>
</c:if>
<c:if test="${param.success == '1'}">
    <div class="global-alert global-alert--success">
        Operation realisee avec succes.
    </div>
</c:if>

<script>
    (function() {
        if (!document.body) return;
        var roleClass = '';
        var pageClass = 'page-${pageKey}';
        <c:choose>
            <c:when test="${isClientRole}">
                roleClass = 'role-client';
            </c:when>
            <c:when test="${isAdminRole}">
                roleClass = 'role-admin';
            </c:when>
        </c:choose>
        if (roleClass) {
            document.body.classList.add(roleClass);
        }
        if (pageClass) {
            document.body.classList.add(pageClass);
        }
    })();

function toggleLanguage() {
    alert('Bascule de langue a venir');
}

function logout() {
    if (confirm('Voulez-vous vous deconnecter ?')) {
        window.location.href = '<c:url value="/logout"/>';
    }
}
</script>
