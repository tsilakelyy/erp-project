<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Article Detail - ERP System</title>
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
        }
        .main-content {
            margin-left: 250px;
            padding: 20px;
        }
        .detail-container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            max-width: 600px;
        }
        .topbar {
            background-color: white;
            padding: 15px 20px;
            border-bottom: 1px solid #ddd;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }
        .detail-label {
            font-weight: bold;
            color: #666;
        }
        .detail-value {
            color: #333;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div style="padding: 0 20px; margin-bottom: 30px; border-bottom: 1px solid #444; padding-bottom: 20px;">
            <h4 style="color: white; margin: 0;">ERP</h4>
        </div>
        <a href="/erp-system/dashboard">Dashboard</a>
        <a href="/erp-system/articles" class="active">Articles</a>
    </div>

    <div class="main-content">
        <div class="topbar">
            <h1>${article.name}</h1>
        </div>

        <div class="detail-container">
            <div class="detail-row">
                <span class="detail-label">Code:</span>
                <span class="detail-value">${article.code}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Description:</span>
                <span class="detail-value">${article.description}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Unit:</span>
                <span class="detail-value">${article.unit.name}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Purchase Price:</span>
                <span class="detail-value">$${article.purchasePrice}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Selling Price:</span>
                <span class="detail-value">$${article.sellingPrice}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Min Stock:</span>
                <span class="detail-value">${article.minStock}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Max Stock:</span>
                <span class="detail-value">${article.maxStock}</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Status:</span>
                <span class="detail-value">
                    <c:if test="${article.active}">
                        <span class="badge bg-success">Active</span>
                    </c:if>
                    <c:if test="${!article.active}">
                        <span class="badge bg-danger">Inactive</span>
                    </c:if>
                </span>
            </div>

            <div style="margin-top: 20px;">
                <a href="/erp-system/articles/${article.id}/edit" class="btn btn-primary">Edit</a>
                <a href="/erp-system/articles" class="btn btn-secondary">Back</a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
