<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Warehouse - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Warehouse Dashboard</h1>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Items in Stock</div>
                    <div class="kpi-value" id="itemsCount">0</div>
                    <div class="kpi-unit">Total articles</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Capacity Usage</div>
                    <div class="kpi-value" id="capacityUsage">0%</div>
                    <div class="kpi-trend trend-up">+5%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Low Stock Items</div>
                    <div class="kpi-value" id="lowStockCount">0</div>
                    <div class="kpi-unit">Need replenishment</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Pending Orders</div>
                    <div class="kpi-value" id="pendingOrders">0</div>
                    <div class="kpi-unit">To be received</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Stock by Category</h3>
                    <canvas id="stockByCategory"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Warehouse Capacity</h3>
                    <canvas id="capacityChart"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Stock Movement Trend</h3>
                    <canvas id="movementTrendChart"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Low Stock Items</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Article Code</th>
                            <th>Description</th>
                            <th>Current Stock</th>
                            <th>Min Level</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="lowStockTable">
                        <!-- Populated by JavaScript -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script src="<c:url value='/assets/js/dashboard.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadWarehouseDashboard();
        });

        function loadWarehouseDashboard() {
            loadStockMetrics();
            loadLowStockItems();
            loadCharts();
        }

        function loadStockMetrics() {
            ajaxCall('/erp/api/stock-levels/metrics', 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('itemsCount').textContent = metrics.itemsCount || 0;
                    document.getElementById('capacityUsage').textContent = (metrics.capacityUsage || 0) + '%';
                    document.getElementById('lowStockCount').textContent = metrics.lowStockCount || 0;
                    document.getElementById('pendingOrders').textContent = metrics.pendingOrders || 0;
                },
                function(error) { console.error('Failed to load metrics'); }
            );
        }

        function loadLowStockItems() {
            ajaxCall('/erp/api/stock-levels/low-stock', 'GET', null,
                function(response) {
                    const items = response.data || response;
                    displayLowStockItems(items);
                },
                function(error) { console.error('Failed to load low stock items'); }
            );
        }

        function displayLowStockItems(items) {
            const tbody = document.getElementById('lowStockTable');
            tbody.innerHTML = '';

            if (!items || items.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5">No low stock items</td></tr>';
                return;
            }

            items.slice(0, 10).forEach(item => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${item.codeArticle}</td>
                    <td>${item.libelle}</td>
                    <td>${item.quantiteCourante}</td>
                    <td>${item.quantiteMin}</td>
                    <td>
                        <button class="btn btn-sm btn-primary" onclick="orderMore('${item.codeArticle}')">Order</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function orderMore(code) {
            showSuccess('Purchase order created for ' + code);
            // Redirect to create purchase order
            window.location.href = '/erp/purchases/create?article=' + code;
        }

        function loadCharts() {
            // Stock by Category
            Dashboard.createChart('stockByCategory', 'pie', {
                labels: ['Electronics', 'Raw Materials', 'Finished Goods', 'Components'],
                datasets: [{
                    data: [30, 25, 35, 10],
                    backgroundColor: ['#007bff', '#28a745', '#ffc107', '#dc3545']
                }]
            });

            // Warehouse Capacity
            Dashboard.createChart('capacityChart', 'bar', {
                labels: ['Main', 'Secondary', 'Transit'],
                datasets: [{
                    label: 'Used %',
                    data: [75, 55, 40],
                    backgroundColor: '#007bff'
                }]
            });

            // Stock Movement Trend
            Dashboard.createChart('movementTrendChart', 'line', {
                labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                datasets: [
                    {
                        label: 'Inbound',
                        data: [120, 150, 100, 180],
                        borderColor: '#28a745',
                        fill: false
                    },
                    {
                        label: 'Outbound',
                        data: [100, 120, 110, 140],
                        borderColor: '#dc3545',
                        fill: false
                    }
                ]
            });
        }
    </script>
</body>
</html>
