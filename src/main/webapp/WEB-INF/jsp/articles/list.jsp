<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Articles - ERP System</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <style>
        body { background-color: #f5f5f5; }
        .sidebar {
            background-color: #2c3e50;
            min-height: 100vh;
            position: fixed;
            width: 250px;
            left: 0;
            top: 0;
            padding-top: 20px;
        }
        .sidebar a {
            color: white;
            display: block;
            padding: 15px 20px;
            text-decoration: none;
            transition: 0.3s;
            border-left: 4px solid transparent;
        }
        .sidebar a:hover { background-color: #34495e; border-left-color: #667eea; }
        .main-content {
            margin-left: 250px;
            padding: 20px;
        }
        .table-container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        .topbar {
            background-color: white;
            padding: 15px 20px;
            border-bottom: 1px solid #ddd;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div style="padding: 0 20px; margin-bottom: 30px; border-bottom: 1px solid #444; padding-bottom: 20px;">
            <h4 style="color: white; margin: 0;">ERP System</h4>
        </div>
        <a href="/erp-system/dashboard">Dashboard</a>
        <a href="/erp-system/purchases/orders">Purchases</a>
        <a href="/erp-system/sales/orders">Sales</a>
        <a href="/erp-system/stocks">Stocks</a>
        <a href="/erp-system/inventories">Inventories</a>
        <div style="padding: 15px 20px; color: #999; font-size: 12px; margin-top: 20px;">REFERENTIALS</div>
        <a href="/erp-system/articles" class="active">Articles</a>
        <a href="/erp-system/suppliers">Suppliers</a>
        <a href="/erp-system/customers">Customers</a>
        <div style="padding: 15px 20px; color: #999; font-size: 12px; margin-top: 20px;">ADMIN</div>
        <a href="/erp-system/admin">Administration</a>
    </div>

    <div class="main-content">
        <div class="topbar">
            <h1>Articles</h1>
            <div>
                <a href="/erp-system/articles/new" class="btn btn-primary">+ New Article</a>
                <a href="/erp-system/logout" class="btn btn-danger" style="margin-left: 10px;">Logout</a>
            </div>
        </div>

        <div class="table-container">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Code</th>
                        <th>Name</th>
                        <th>Unit</th>
                        <th>Purchase Price</th>
                        <th>Selling Price</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${articles}" var="article">
                        <tr>
                            <td>${article.code}</td>
                            <td>${article.name}</td>
                            <td>${article.unit.code}</td>
                            <td>$${article.purchasePrice}</td>
                            <td>$${article.sellingPrice}</td>
                            <td>
                                <c:if test="${article.active}">
                                    <span class="badge bg-success">Active</span>
                                </c:if>
                                <c:if test="${!article.active}">
                                    <span class="badge bg-danger">Inactive</span>
                                </c:if>
                            </td>
                            <td>
                                <a href="/erp-system/articles/${article.id}" class="btn btn-sm btn-info">View</a>
                                <form method="POST" action="/erp-system/articles/${article.id}/deactivate" style="display:inline;">
                                    <button type="submit" class="btn btn-sm btn-warning">Deactivate</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
