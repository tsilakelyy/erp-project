<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Analytics Report - ERP</title>
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
                <h1>Purchase Analytics Report</h1>
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
                    <label>Supplier:</label>
                    <select id="supplier" onchange="refreshReport()">
                        <option value="">All Suppliers</option>
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
                        <div class="metric-label">Total Amount</div>
                        <div class="metric-value" id="totalAmount">0.00€</div>
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
                    <h3>Orders by Supplier</h3>
                    <canvas id="ordersBySupplierChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3>Amount by Supplier</h3>
                    <canvas id="amountBySupplierChart"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Detailed Orders</h3>
                <table class="table" id="ordersTable">
                    <thead>
                        <tr>
                            <th>Order #</th>
                            <th>Supplier</th>
                            <th>Order Date</th>
                            <th>Expected Delivery</th>
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
            loadSuppliers();
            generateReport();
        });

        function loadSuppliers() {
            ajaxCall('/erp/api/suppliers', 'GET', null,
                function(response) {
                    const suppliers = response.data || response;
                    populateSupplierFilter(suppliers);
                },
                function(error) { console.error('Failed to load suppliers'); }
            );
        }

        function populateSupplierFilter(suppliers) {
            const select = document.getElementById('supplier');
            suppliers.forEach(supplier => {
                const option = document.createElement('option');
                option.value = supplier.id;
                option.textContent = supplier.libelle;
                select.appendChild(option);
            });
        }

        function generateReport() {
            const dateFrom = document.getElementById('dateFrom').value;
            const dateTo = document.getElementById('dateTo').value;
            const supplier = document.getElementById('supplier').value;

            let url = '/erp/api/reports/purchases?';
            const params = [];
            if (dateFrom) params.push('from=' + dateFrom);
            if (dateTo) params.push('to=' + dateTo);
            if (supplier) params.push('supplier=' + supplier);

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
            document.getElementById('totalAmount').textContent = formatCurrency(data.totalAmount || 0);
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
                    <td>${order.fournisseurLibelle}</td>
                    <td>${new Date(order.dateCreation).toLocaleDateString()}</td>
                    <td>${new Date(order.dateExpectedDelivery).toLocaleDateString()}</td>
                    <td>${formatCurrency(order.montantTotal)}</td>
                    <td>${status}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts(data) {
            // Chart 1: Orders by Supplier
            const suppliers = {};
            const amounts = {};
            
            (data.orders || []).forEach(order => {
                const supplier = order.fournisseurLibelle;
                suppliers[supplier] = (suppliers[supplier] || 0) + 1;
                amounts[supplier] = (amounts[supplier] || 0) + (order.montantTotal || 0);
            });

            Dashboard.createChart('ordersBySupplierChart', 'bar', {
                labels: Object.keys(suppliers),
                datasets: [{
                    label: 'Order Count',
                    data: Object.values(suppliers),
                    backgroundColor: '#007bff'
                }]
            });

            Dashboard.createChart('amountBySupplierChart', 'bar', {
                labels: Object.keys(amounts),
                datasets: [{
                    label: 'Amount',
                    data: Object.values(amounts),
                    backgroundColor: '#28a745'
                }]
            });
        }

        function refreshReport() {
            generateReport();
        }

        function exportReport() {
            const filename = 'purchase-report-' + new Date().toISOString().split('T')[0] + '.pdf';
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
