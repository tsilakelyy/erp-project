<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create Article - ERP System</title>
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
        .sidebar a:hover { background-color: #34495e; }
        .main-content {
            margin-left: 250px;
            padding: 20px;
        }
        .form-container {
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
            <h4 style="color: white; margin: 0;">ERP</h4>
        </div>
        <a href="/erp-system/dashboard">Dashboard</a>
        <a href="/erp-system/articles" class="active">Articles</a>
    </div>

    <div class="main-content">
        <div class="topbar">
            <h1>New Article</h1>
        </div>

        <div class="form-container">
            <form method="POST" action="/erp-system/articles">
                <div class="mb-3">
                    <label for="code" class="form-label">Code *</label>
                    <input type="text" class="form-control" id="code" name="code" required>
                </div>

                <div class="mb-3">
                    <label for="name" class="form-label">Name *</label>
                    <input type="text" class="form-control" id="name" name="name" required>
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label">Description</label>
                    <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                </div>

                <div class="mb-3">
                    <label for="purchasePrice" class="form-label">Purchase Price *</label>
                    <input type="number" step="0.01" class="form-control" id="purchasePrice" name="purchasePrice" required>
                </div>

                <div class="mb-3">
                    <label for="sellingPrice" class="form-label">Selling Price *</label>
                    <input type="number" step="0.01" class="form-control" id="sellingPrice" name="sellingPrice" required>
                </div>

                <div class="mb-3">
                    <label for="minStock" class="form-label">Min Stock</label>
                    <input type="number" class="form-control" id="minStock" name="minStock" value="10">
                </div>

                <div class="mb-3">
                    <label for="maxStock" class="form-label">Max Stock</label>
                    <input type="number" class="form-control" id="maxStock" name="maxStock" value="1000">
                </div>

                <div class="mb-3 form-check">
                    <input type="checkbox" class="form-check-input" id="tracked" name="tracked">
                    <label class="form-check-label" for="tracked">Track by batch/serial</label>
                </div>

                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary btn-lg">Create Article</button>
                    <a href="/erp-system/articles" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
