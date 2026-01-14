<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ERP - Error 403</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <style>
        .error-container {
            margin-top: 100px;
            text-align: center;
            padding: 50px;
        }
        .error-code {
            font-size: 72px;
            font-weight: bold;
            color: #dc3545;
        }
        .error-message {
            font-size: 24px;
            margin-bottom: 20px;
        }
        .error-description {
            font-size: 16px;
            color: #666;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">403</div>
        <div class="error-message">Access Denied</div>
        <div class="error-description">You do not have permission to access this resource.</div>
        <a href="<c:url value='/erp/dashboard'/>" class="btn btn-primary">Go to Dashboard</a>
    </div>
</body>
</html>
