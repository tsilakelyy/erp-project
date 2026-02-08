<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="isAdmin" value="false" />
<c:set var="isClient" value="false" />
<c:forEach items="${sessionScope.user.roles}" var="role">
    <c:if test="${role.code == 'ADMIN'}">
        <c:set var="isAdmin" value="true" />
    </c:if>
    <c:if test="${role.code == 'CLIENT'}">
        <c:set var="isClient" value="true" />
    </c:if>
</c:forEach>

<aside class="sidebar">
    <ul class="sidebar-menu">
        <li class="sidebar-menu-item">
            <a href="<c:url value='/dashboard'/>" class="sidebar-menu-link">
                Tableau de bord
            </a>
        </li>

        <c:if test="${!isClient}">
            <li class="sidebar-menu-item has-submenu">
                <a href="#" class="sidebar-menu-link">Tableaux de bord</a>
                <ul class="sidebar-submenu">
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/dashboard/achats'/>" class="sidebar-menu-link">
                            Achats
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/dashboard/ventes'/>" class="sidebar-menu-link">
                            Ventes
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/dashboard/stocks'/>" class="sidebar-menu-link">
                            Stocks
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/dashboard/finance'/>" class="sidebar-menu-link">
                            Finance
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/dashboard/direction'/>" class="sidebar-menu-link">
                            Direction
                        </a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-menu-item has-submenu">
                <a href="#" class="sidebar-menu-link">Rapports</a>
                <ul class="sidebar-submenu">
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/reports'/>" class="sidebar-menu-link">
                            Vue globale
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/reports/purchases'/>" class="sidebar-menu-link">
                            Analyse achats
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/reports/sales'/>" class="sidebar-menu-link">
                            Analyse ventes
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/reports/inventory'/>" class="sidebar-menu-link">
                            Etat des stocks
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/reports/financial'/>" class="sidebar-menu-link">
                            Rapport financier
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/reports/validations'/>" class="sidebar-menu-link">
                            Suivi validations
                        </a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-menu-item has-submenu">
                <a href="#" class="sidebar-menu-link">Achats</a>
                <ul class="sidebar-submenu">
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/purchases/requests'/>" class="sidebar-menu-link">
                            Demandes d'achat
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/purchases/proformas'/>" class="sidebar-menu-link">
                            Proformas
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/purchases/orders'/>" class="sidebar-menu-link">
                            Commandes
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/purchases/receipts'/>" class="sidebar-menu-link">
                            Receptions
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/purchases/invoices'/>" class="sidebar-menu-link">
                            Factures achat
                        </a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-menu-item has-submenu">
                <a href="#" class="sidebar-menu-link">Ventes</a>
                <ul class="sidebar-submenu">
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/sales/proformas'/>" class="sidebar-menu-link">
                            Proformas clients
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/sales/orders'/>" class="sidebar-menu-link">
                            Commandes
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/sales/client-requests'/>" class="sidebar-menu-link">
                            Demandes clients
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/sales/bons'/>" class="sidebar-menu-link">
                            Bons clients
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/sales/deliveries'/>" class="sidebar-menu-link">
                            Livraisons
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/sales/invoices'/>" class="sidebar-menu-link">
                            Factures
                        </a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-menu-item has-submenu">
                <a href="#" class="sidebar-menu-link">Stock</a>
                <ul class="sidebar-submenu">
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/stocks'/>" class="sidebar-menu-link">
                            Niveaux de stock
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/inventories'/>" class="sidebar-menu-link">
                            Inventaires
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/warehouses'/>" class="sidebar-menu-link">
                            Entrepots
                        </a>
                    </li>
                </ul>
            </li>

            <li class="sidebar-menu-item has-submenu">
                <a href="#" class="sidebar-menu-link">Referentiels</a>
                <ul class="sidebar-submenu">
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/articles'/>" class="sidebar-menu-link">
                            Articles
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin/categories'/>" class="sidebar-menu-link">
                            Catégories d'articles
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin/pricing-lists'/>" class="sidebar-menu-link">
                            Listes de prix
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/suppliers'/>" class="sidebar-menu-link">
                            Fournisseurs
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/customers'/>" class="sidebar-menu-link">
                            Clients
                        </a>
                    </li>
                </ul>
            </li>
        </c:if>

        <c:if test="${isClient}">
            <li class="sidebar-menu-item has-submenu">
                <a href="#" class="sidebar-menu-link">Espace client</a>
                <ul class="sidebar-submenu">
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/client'/>" class="sidebar-menu-link">
                            Tableau client
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/client/orders'/>" class="sidebar-menu-link">
                            Mes commandes
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/client/deliveries'/>" class="sidebar-menu-link">
                            Mes livraisons
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/client/invoices'/>" class="sidebar-menu-link">
                            Mes factures
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/client/profile'/>" class="sidebar-menu-link">
                            Mon profil
                        </a>
                    </li>
                </ul>
            </li>
        </c:if>

        <c:if test="${isAdmin}">
            <li class="sidebar-menu-item has-submenu">
                <a href="#" class="sidebar-menu-link">Administration</a>
                <ul class="sidebar-submenu">
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin'/>" class="sidebar-menu-link">
                            Tableau admin
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin/users'/>" class="sidebar-menu-link">
                            Utilisateurs
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin/sites'/>" class="sidebar-menu-link">
                            Sites
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin/warehouses'/>" class="sidebar-menu-link">
                            Entrepots
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin/units'/>" class="sidebar-menu-link">
                            Unites
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin/taxes'/>" class="sidebar-menu-link">
                            Taxes
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin/categories'/>" class="sidebar-menu-link">
                            Catégories d'articles
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/admin/pricing-lists'/>" class="sidebar-menu-link">
                            Listes de prix
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="<c:url value='/client'/>" class="sidebar-menu-link">
                            Front office (Apercu)
                        </a>
                    </li>
                </ul>
            </li>
        </c:if>
    </ul>
</aside>

<script src="<c:url value='/assets/js/sidebar.js'/>"></script>
<script src="<c:url value='/assets/js/smart-tables.js'/>"></script>
<script src="<c:url value='/assets/js/page-filters.js'/>"></script>
<script src="<c:url value='/assets/js/table-modal.js'/>"></script>
