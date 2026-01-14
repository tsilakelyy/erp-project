<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Analytics Report - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/css/style-tables.css'/>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Sales Analytics Report</h1>
                <button class="btn btn-primary" onclick="generateReport()">Generate Report</button>
                <button class="btn btn-secondary" onclick="exportReport()">Export PDF</button>
            </div>

            <div class="filters">
                <div class="filter-group">
                    <label>Date From:</label>
                    <input type="date" id="dateFrom" onchange="refreshReport()">
                </div>
                <div class="filter-group">
                    <label>Date To:</label>
                    <input type="date" id="dateTo" onchange="refreshReport()">
                </div>
                <div class="filter-group">
                    <label>Customer:</label>
                    <select id="customer" onchange="refreshReport()">
                        <option value="">All Customers</option>
                    </select>
                </div>
            </div>

            <div class="report-section">
                <h3>Summary Metrics</h3>
                <div class="metrics-grid">
                    <div class="metric-box">
                        <div class="metric-label">Total Orders</div>
                        <div class="metric-value" id="totalOrders">0</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Total Revenue</div>
                        <div class="metric-value" id="totalRevenue">0.00€</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Avg Order Value</div>
                        <div class="metric-value" id="avgOrder">0.00€</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Pending Delivery</div>
                        <div class="metric-value" id="pendingDelivery">0</div>
                    </div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Orders by Customer</h3>
                    <canvas id="ordersByCustomerChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3>Revenue by Customer</h3>
                    <canvas id="revenueByCustomerChart"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Detailed Orders</h3>
                <table class="table" id="ordersTable">
                    <thead>
                        <tr>
                            <th>Order #</th>
                            <th>Customer</th>
                            <th>Order Date</th>
                            <th>Delivery Date</th>
                            <th>Amount</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="ordersList">
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
            loadCustomers();
            generateReport();
        });

        function loadCustomers() {
            ajaxCall('/erp/api/customers', 'GET', null,
                function(response) {
                    const customers = response.data || response;
                    populateCustomerFilter(customers);
                },
                function(error) { console.error('Failed to load customers'); }
            );
        }

        function populateCustomerFilter(customers) {
            const select = document.getElementById('customer');
            customers.forEach(customer => {
                const option = document.createElement('option');
                option.value = customer.id;
                option.textContent = customer.libelle;
                select.appendChild(option);
            });
        }

        function generateReport() {
            const dateFrom = document.getElementById('dateFrom').value;
            const dateTo = document.getElementById('dateTo').value;
            const customer = document.getElementById('customer').value;

            let url = '/erp/api/reports/sales?';
            const params = [];
            if (dateFrom) params.push('from=' + dateFrom);
            if (dateTo) params.push('to=' + dateTo);
            if (customer) params.push('customer=' + customer);

            ajaxCall(url + params.join('&'), 'GET', null,
                function(response) {
                    const data = response.data || response;
                    displayReportData(data);
                },
                function(error) { showError('Failed to generate report'); }
            );
        }

        function displayReportData(data) {
            if (!data) return;

            document.getElementById('totalOrders').textContent = data.totalOrders || 0;
            document.getElementById('totalRevenue').textContent = formatCurrency(data.totalRevenue || 0);
            document.getElementById('avgOrder').textContent = formatCurrency(data.avgOrderValue || 0);
            document.getElementById('pendingDelivery').textContent = data.pendingOrders || 0;

            displayOrders(data.orders || []);
            loadCharts(data);
        }

        function displayOrders(orders) {
            const tbody = document.getElementById('ordersList');
            tbody.innerHTML = '';

            if (!orders || orders.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">No orders found</td></tr>';
                return;
            }

            orders.forEach(order => {
                const tr = document.createElement('tr');
                const statusClass = order.statut === 'DELIVERED' ? 'success' : order.statut === 'PENDING' ? 'warning' : 'info';
                const status = `<span class="badge badge-${statusClass}">${order.statut}</span>`;

                tr.innerHTML = `
                    <td>${order.numero}</td>
                    <td>${order.clientLibelle}</td>
                    <td>${new Date(order.dateCreation).toLocaleDateString()}</td>
                    <td>${new Date(order.dateExpectedDelivery).toLocaleDateString()}</td>
                    <td>${formatCurrency(order.montantTotal)}</td>
                    <td>${status}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts(data) {
            // Chart 1: Orders by Customer
            const customers = {};
            const revenues = {};
            
            (data.orders || []).forEach(order => {
                const customer = order.clientLibelle;
                customers[customer] = (customers[customer] || 0) + 1;
                revenues[customer] = (revenues[customer] || 0) + (order.montantTotal || 0);
            });

            Dashboard.createChart('ordersByCustomerChart', 'bar', {
                labels: Object.keys(customers),
                datasets: [{
                    label: 'Order Count',
                    data: Object.values(customers),
                    backgroundColor: '#007bff'
                }]
            });

            Dashboard.createChart('revenueByCustomerChart', 'bar', {
                labels: Object.keys(revenues),
                datasets: [{
                    label: 'Revenue',
                    data: Object.values(revenues),
                    backgroundColor: '#28a745'
                }]
            });
        }

        function refreshReport() {
            generateReport();
        }

        function exportReport() {
            window.print();
        }

        function formatCurrency(amount) {
            return new Intl.NumberFormat('fr-FR', {
                style: 'currency',
                currency: 'EUR'
            }).format(amount);
        }
    </script>

    <style>
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }

        .metric-box {
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 5px;
            text-align: center;
        }

        .metric-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 10px;
        }

        .metric-value {
            font-size: 24px;
            font-weight: bold;
            color: #333;
        }
    </style>
</body>
</html>
