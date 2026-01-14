<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Sales - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Sales Dashboard</h1>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Total Sales</div>
                    <div class="kpi-value" id="totalSales">0.00€</div>
                    <div class="kpi-trend trend-up">+15%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Orders This Month</div>
                    <div class="kpi-value" id="ordersCount">0</div>
                    <div class="kpi-unit">Sale orders</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Pending Orders</div>
                    <div class="kpi-value" id="pendingOrders">0</div>
                    <div class="kpi-unit">To be processed</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Avg Order Value</div>
                    <div class="kpi-value" id="avgOrderValue">0.00€</div>
                    <div class="kpi-trend trend-up">+5%</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Sales by Customer</h3>
                    <canvas id="salesByCustomer"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Monthly Revenue</h3>
                    <canvas id="monthlyRevenue"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Order Status</h3>
                    <canvas id="orderStatus"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Recent Sales Orders</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Order #</th>
                            <th>Customer</th>
                            <th>Amount</th>
                            <th>Order Date</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="recentSalesOrders">
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
            loadSalesDashboard();
        });

        function loadSalesDashboard() {
            loadSalesMetrics();
            loadRecentSalesOrders();
            loadCharts();
        }

        function loadSalesMetrics() {
            ajaxCall('/erp/api/sales-orders/metrics', 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('totalSales').textContent = formatCurrency(metrics.totalSales || 0);
                    document.getElementById('ordersCount').textContent = metrics.ordersCount || 0;
                    document.getElementById('pendingOrders').textContent = metrics.pendingOrders || 0;
                    document.getElementById('avgOrderValue').textContent = formatCurrency(metrics.avgOrderValue || 0);
                },
                function(error) { console.error('Failed to load metrics'); }
            );
        }

        function loadRecentSalesOrders() {
            ajaxCall('/erp/api/sales-orders?size=10&sort=dateCreation,desc', 'GET', null,
                function(response) {
                    const orders = response.data || response;
                    displayRecentSalesOrders(orders);
                },
                function(error) { console.error('Failed to load orders'); }
            );
        }

        function displayRecentSalesOrders(orders) {
            const tbody = document.getElementById('recentSalesOrders');
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
                    <td>${order.clientLibelle || '-'}</td>
                    <td>${formatCurrency(order.montantTotal || 0)}</td>
                    <td>${new Date(order.dateCreation).toLocaleDateString()}</td>
                    <td>${status}</td>
                    <td><a href="/erp/sales/detail/${order.id}">View</a></td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts() {
            // Sales by Customer
            Dashboard.createChart('salesByCustomer', 'bar', {
                labels: ['Customer A', 'Customer B', 'Customer C', 'Customer D', 'Customer E'],
                datasets: [{
                    label: 'Sales Amount',
                    data: [35000, 28000, 22000, 18000, 15000],
                    backgroundColor: '#28a745'
                }]
            });

            // Monthly Revenue
            Dashboard.createChart('monthlyRevenue', 'line', {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Revenue',
                    data: [85000, 92000, 78000, 105000, 98000, 115000],
                    borderColor: '#007bff',
                    fill: false
                }]
            });

            // Order Status
            Dashboard.createChart('orderStatus', 'doughnut', {
                labels: ['Completed', 'Pending', 'Cancelled'],
                datasets: [{
                    data: [70, 20, 10],
                    backgroundColor: ['#28a745', '#ffc107', '#dc3545']
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
