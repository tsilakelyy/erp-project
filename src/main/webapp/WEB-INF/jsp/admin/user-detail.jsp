<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Detail - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>User Detail</h1>
                <a href="<c:url value='/admin/users'/>" class="btn btn-secondary">Retour</a>
            </div>

            <div class="detail-container">
                <div class="detail-row">
                    <span class="detail-label">Login:</span>
                    <span class="detail-value">${user.login}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Email:</span>
                    <span class="detail-value">${user.email}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Name:</span>
                    <span class="detail-value">${user.nom} ${user.prenom}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span class="detail-value">
                        <c:if test="${user.active}">
                            <span class="badge badge-success">Active</span>
                        </c:if>
                        <c:if test="${!user.active}">
                            <span class="badge badge-danger">Inactive</span>
                        </c:if>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Last Login:</span>
                    <span class="detail-value">${user.dateLastLogin}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Roles:</span>
                    <span class="detail-value">
                        <c:forEach items="${user.roles}" var="role" varStatus="status">
                            ${role.libelle}<c:if test="${!status.last}">, </c:if>
                        </c:forEach>
                    </span>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
