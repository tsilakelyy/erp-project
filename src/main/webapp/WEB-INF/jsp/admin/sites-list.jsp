<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sites - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Sites</h1>
                <a href="<c:url value='/admin'/>" class="btn btn-secondary">Retour</a>
            </div>

            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Name</th>
                            <th>Address</th>
                            <th>City</th>
                            <th>Zip</th>
                            <th>Country</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${sites}" var="site">
                            <tr>
                                <td>${site.code}</td>
                                <td>${site.name}</td>
                                <td>${site.address}</td>
                                <td>${site.city}</td>
                                <td>${site.zipCode}</td>
                                <td>${site.country}</td>
                                <td>
                                    <c:if test="${site.active}">
                                        <span class="badge badge-success">Active</span>
                                    </c:if>
                                    <c:if test="${!site.active}">
                                        <span class="badge badge-danger">Inactive</span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
