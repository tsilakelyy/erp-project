<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ERP System - Dashboard</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.0/dist/chart.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            background-color: #f5f5f5;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
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
        .sidebar a:hover,
        .sidebar a.active {
            background-color: #34495e;
            border-left-color: #667eea;
        }
        .main-content {
            margin-left: 250px;
            padding: 20px;
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
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .card-stat {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            border-left: 4px solid #667eea;
        }
        .card-stat h3 {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .card-stat .value {
            font-size: 28px;
            font-weight: bold;
            color: #667eea;
        }
        .chart-container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div style="padding: 0 20px; margin-bottom: 30px; border-bottom: 1px solid #444; padding-bottom: 20px;">
            <h4 style="color: white; margin: 0;">ERP System</h4>
        </div>
        <a href="/erp-system/dashboard" class="active">Dashboard</a>
        <a href="/erp-system/purchases/orders">Purchases</a>
        <a href="/erp-system/sales/orders">Sales</a>
        <a href="/erp-system/stocks">Stocks</a>
        <a href="/erp-system/inventories">Inventories</a>
        <div style="padding: 15px 20px; color: #999; font-size: 12px; margin-top: 20px;">REFERENTIALS</div>
        <a href="/erp-system/articles">Articles</a>
        <a href="/erp-system/suppliers">Suppliers</a>
        <a href="/erp-system/customers">Customers</a>
        <div style="padding: 15px 20px; color: #999; font-size: 12px; margin-top: 20px;">ADMIN</div>
        <a href="/erp-system/admin">Administration</a>
    </div>

    <div class="main-content">
        <div class="topbar">
            <h1>Dashboard</h1>
            <div>
                <span>${username}</span>
                <a href="/erp-system/logout" class="btn btn-sm btn-danger" style="margin-left: 20px;">Logout</a>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="card-stat">
                <h3>Pending Orders</h3>
                <div class="value">5</div>
            </div>
            <div class="card-stat" style="border-left-color: #e74c3c;">
                <h3>Stock Value</h3>
                <div class="value" style="color: #e74c3c;">$150,000</div>
            </div>
            <div class="card-stat" style="border-left-color: #2ecc71;">
                <h3>Revenue Today</h3>
                <div class="value" style="color: #2ecc71;">$45,000</div>
            </div>
            <div class="card-stat" style="border-left-color: #f39c12;">
                <h3>Invoices Pending</h3>
                <div class="value" style="color: #f39c12;">12</div>
            </div>
        </div>

        <div class="chart-container">
            <h5>Monthly Sales</h5>
            <canvas id="salesChart" style="max-height: 300px;"></canvas>
        </div>

        <div class="chart-container">
            <h5>Stock Movement</h5>
            <canvas id="stockChart" style="max-height: 300px;"></canvas>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Sales Chart
        const salesCtx = document.getElementById('salesChart').getContext('2d');
        new Chart(salesCtx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Sales',
                    data: [12000, 19000, 15000, 25000, 22000, 30000],
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: { display: true }
                }
            }
        });

        // Stock Chart
        const stockCtx = document.getElementById('stockChart').getContext('2d');
        new Chart(stockCtx, {
            type: 'bar',
            data: {
                labels: ['Electronics', 'Clothing', 'Food', 'Books', 'Other'],
                datasets: [{
                    label: 'Stock Quantity',
                    data: [120, 90, 150, 75, 45],
                    backgroundColor: ['#667eea', '#e74c3c', '#2ecc71', '#f39c12', '#3498db']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true
            }
        });
    </script>
</body>
</html>
