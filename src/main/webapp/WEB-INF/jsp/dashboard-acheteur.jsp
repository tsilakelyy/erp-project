<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Purchasing - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Purchasing Dashboard</h1>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Total Purchase Orders</div>
                    <div class="kpi-value" id="totalOrders">0</div>
                    <div class="kpi-unit">This month</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Total Spend</div>
                    <div class="kpi-value" id="totalSpend">0.00€</div>
                    <div class="kpi-trend trend-up">+8%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Pending Orders</div>
                    <div class="kpi-value" id="pendingCount">0</div>
                    <div class="kpi-unit">Awaiting delivery</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Avg Delivery Time</div>
                    <div class="kpi-value" id="avgDelivery">0 days</div>
                    <div class="kpi-unit">Expected</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Purchase Orders by Supplier</h3>
                    <canvas id="ordersBySupplier"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Order Status Distribution</h3>
                    <canvas id="statusDistribution"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Monthly Spending Trend</h3>
                    <canvas id="spendingTrend"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Recent Purchase Orders</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Order #</th>
                            <th>Supplier</th>
                            <th>Amount</th>
                            <th>Due Date</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="recentOrders">
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
            loadPurchasingDashboard();
        });

        function loadPurchasingDashboard() {
            loadPurchaseMetrics();
            loadRecentOrders();
            loadCharts();
        }

        function loadPurchaseMetrics() {
            ajaxCall('/erp/api/purchase-orders/metrics', 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('totalOrders').textContent = metrics.totalOrders || 0;
                    document.getElementById('totalSpend').textContent = formatCurrency(metrics.totalSpend || 0);
                    document.getElementById('pendingCount').textContent = metrics.pendingCount || 0;
                    document.getElementById('avgDelivery').textContent = (metrics.avgDeliveryDays || 0) + ' days';
                },
                function(error) { console.error('Failed to load metrics'); }
            );
        }

        function loadRecentOrders() {
            ajaxCall('/erp/api/purchase-orders?size=10&sort=dateCreation,desc', 'GET', null,
                function(response) {
                    const orders = response.data || response;
                    displayRecentOrders(orders);
                },
                function(error) { console.error('Failed to load orders'); }
            );
        }

        function displayRecentOrders(orders) {
            const tbody = document.getElementById('recentOrders');
            tbody.innerHTML = '';

            if (!orders || orders.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">No orders</td></tr>';
                return;
            }

            orders.forEach(order => {
                const tr = document.createElement('tr');
                const statusClass = order.statut === 'DELIVERED' ? 'success' : order.statut === 'PENDING' ? 'warning' : 'info';
                const status = `<span class="badge badge-${statusClass}">${order.statut}</span>`;

                tr.innerHTML = `
                    <td>${order.numero}</td>
                    <td>${order.fournisseurLibelle || '-'}</td>
                    <td>${formatCurrency(order.montantTotal || 0)}</td>
                    <td>${new Date(order.dateExpectedDelivery).toLocaleDateString()}</td>
                    <td>${status}</td>
                    <td><a href="/erp/purchases/detail/${order.id}">View</a></td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts() {
            // Orders by Supplier
            Dashboard.createChart('ordersBySupplier', 'bar', {
                labels: ['Supplier A', 'Supplier B', 'Supplier C', 'Supplier D', 'Supplier E'],
                datasets: [{
                    label: 'Order Count',
                    data: [15, 12, 10, 8, 6],
                    backgroundColor: '#007bff'
                }]
            });

            // Status Distribution
            Dashboard.createChart('statusDistribution', 'doughnut', {
                labels: ['Delivered', 'Pending', 'Cancelled'],
                datasets: [{
                    data: [60, 30, 10],
                    backgroundColor: ['#28a745', '#ffc107', '#dc3545']
                }]
            });

            // Monthly Spending
            Dashboard.createChart('spendingTrend', 'line', {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Monthly Spending',
                    data: [45000, 52000, 48000, 61000, 58000, 65000],
                    borderColor: '#007bff',
                    fill: false
                }]
            });
        }

        function formatCurrency(amount) {
            return new Intl.NumberFormat('fr-FR', {
                style: 'currency',
                currency: 'EUR'
            }).format(amount);
        }
    </script>
</body>
</html>
