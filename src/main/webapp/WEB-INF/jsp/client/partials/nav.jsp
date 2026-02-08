<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="isAdminRole" value="false" />
<c:if test="${not empty sessionScope.user && not empty sessionScope.user.roles}">
    <c:forEach items="${sessionScope.user.roles}" var="role">
        <c:if test="${role.code == 'ADMIN'}">
            <c:set var="isAdminRole" value="true" />
        </c:if>
    </c:forEach>
</c:if>

<header class="client-nav">
    <div class="client-brand">
        <div class="client-brand-badge">C</div>
        <div>
            <div>Espace Client</div>
            <div style="font-size: 11px; opacity: 0.8;">ERP Multisite</div>
        </div>
    </div>
    <nav class="client-nav-links">
        <a href="<c:url value='/client'/>" class="${pageActive == 'dashboard' ? 'active' : ''}">Tableau</a>
        <div class="client-nav-dropdown">
            <button type="button" class="client-nav-trigger">Purchase</button>
            <div class="client-nav-menu">
                <a href="<c:url value='/client/orders/new'/>">Faire une commande</a>
                <a href="<c:url value='/client/requests/new?type=LIVRAISON'/>">Demander une livraison</a>
                <a href="<c:url value='/client/requests/new?type=BON_REDUCTION'/>">Bon de reduction</a>
                <a href="<c:url value='/client/requests/new?type=BON_ACHAT'/>">Bon d'achat</a>
                <a href="<c:url value='/client/requests/new?type=DEVIS'/>">Demander un proforma</a>
            </div>
        </div>
        <a href="<c:url value='/client/products'/>" class="${pageActive == 'products' ? 'active' : ''}">Produits</a>
        <a href="<c:url value='/client/orders'/>" class="${pageActive == 'orders' ? 'active' : ''}">Commandes</a>
        <a href="<c:url value='/client/deliveries'/>" class="${pageActive == 'deliveries' ? 'active' : ''}">Livraisons</a>
        <a href="<c:url value='/client/invoices'/>" class="${pageActive == 'invoices' ? 'active' : ''}">Factures</a>
        <a href="<c:url value='/client/proformas'/>" class="${pageActive == 'proformas' ? 'active' : ''}">Proformas</a>
        <a href="<c:url value='/client/payments'/>" class="${pageActive == 'payments' ? 'active' : ''}">Paiements</a>
        <a href="<c:url value='/client/requests'/>" class="${pageActive == 'requests' ? 'active' : ''}">Demandes</a>
        <a href="<c:url value='/client/profile'/>" class="${pageActive == 'profile' ? 'active' : ''}">Profil</a>
        <a href="<c:url value='/logout'/>">Deconnexion</a>
    </nav>
</header>
<script src="<c:url value='/assets/js/smart-tables.js'/>"></script>
<script src="<c:url value='/assets/js/page-filters.js'/>"></script>
<script src="<c:url value='/assets/js/table-modal.js'/>"></script>
