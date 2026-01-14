<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<aside class="sidebar">
    <ul class="sidebar-menu">
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/dashboard'/>" class="sidebar-menu-link">
                Dashboard
            </a>
        </li>
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/api/articles'/>" class="sidebar-menu-link">
                Articles
            </a>
        </li>
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/api/suppliers'/>" class="sidebar-menu-link">
                Suppliers
            </a>
        </li>
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/api/customers'/>" class="sidebar-menu-link">
                Customers
            </a>
        </li>
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/api/warehouses'/>" class="sidebar-menu-link">
                Warehouses
            </a>
        </li>
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/api/purchases'/>" class="sidebar-menu-link">
                Purchases
            </a>
        </li>
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/api/sales'/>" class="sidebar-menu-link">
                Sales
            </a>
        </li>
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/api/inventory'/>" class="sidebar-menu-link">
                Inventory
            </a>
        </li>
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/api/stocks'/>" class="sidebar-menu-link">
                Stocks
            </a>
        </li>
        <li class="sidebar-menu-item">
            <a href="<c:url value='/erp/admin'/>" class="sidebar-menu-link">
                Administration
            </a>
        </li>
    </ul>
</aside>

<script src="<c:url value='/assets/js/sidebar.js'/>"></script>
