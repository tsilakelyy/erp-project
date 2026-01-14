<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<header class="header">
    <div class="header-brand">
        <c:url var="dashboardUrl" value="/erp/dashboard"/>
        <a href="${dashboardUrl}" style="color: white; text-decoration: none;">ERP Multisite</a>
    </div>
    <nav class="header-nav">
        <a href="#" onclick="toggleLanguage()">FR/EN</a>
        <a href="#" onclick="logout()">Logout</a>
    </nav>
</header>

<script>
function toggleLanguage() {
    // Language toggle logic
    alert('Language toggle coming soon');
}

function logout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = '<c:url value="/erp/login"/>';
    }
}
</script>
