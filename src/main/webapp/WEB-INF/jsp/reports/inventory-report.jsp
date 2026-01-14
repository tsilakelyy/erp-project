<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Report - ERP</title>
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
                <h1>Inventory Status Report</h1>
                <button class="btn btn-primary" onclick="generateReport()">Generate Report</button>
                <button class="btn btn-secondary" onclick="exportReport()">Export CSV</button>
            </div>

            <div class="filters">
                <div class="filter-group">
                    <label>Warehouse:</label>
                    <select id="warehouse" onchange="refreshReport()">
                        <option value="">All Warehouses</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Stock Status:</label>
                    <select id="stockStatus" onchange="refreshReport()">
                        <option value="">All Status</option>
                        <option value="LOW">Low Stock</option>
                        <option value="OPTIMAL">Optimal</option>
                        <option value="EXCESS">Excess</option>
                    </select>
                </div>
            </div>

            <div class="report-section">
                <h3>Inventory Summary</h3>
                <div class="metrics-grid">
                    <div class="metric-box">
                        <div class="metric-label">Total Items</div>
                        <div class="metric-value" id="totalItems">0</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Total Value</div>
                        <div class="metric-value" id="totalValue">0.00€</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Low Stock Items</div>
                        <div class="metric-value" id="lowStockItems">0</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Avg Turnover</div>
                        <div class="metric-value" id="avgTurnover">0 days</div>
                    </div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Inventory by Warehouse</h3>
                    <canvas id="inventoryByWarehouse"></canvas>
                </div>
                <div class="chart-container">
                    <h3>Stock Status Distribution</h3>
                    <canvas id="stockStatusChart"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Detailed Inventory Levels</h3>
                <table class="table" id="inventoryTable">
                    <thead>
                        <tr>
                            <th>Article Code</th>
                            <th>Description</th>
                            <th>Warehouse</th>
                            <th>Current Stock</th>
                            <th>Minimum Level</th>
                            <th>Unit Value</th>
                            <th>Total Value</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="inventoryList">
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
            loadWarehouses();
            generateReport();
        });

        function loadWarehouses() {
            ajaxCall('/erp/api/warehouses', 'GET', null,
                function(response) {
                    const warehouses = response.data || response;
                    populateWarehouseFilter(warehouses);
                },
                function(error) { console.error('Failed to load warehouses'); }
            );
        }

        function populateWarehouseFilter(warehouses) {
            const select = document.getElementById('warehouse');
            warehouses.forEach(warehouse => {
                const option = document.createElement('option');
                option.value = warehouse.id;
                option.textContent = warehouse.libelle;
                select.appendChild(option);
            });
        }

        function generateReport() {
            const warehouse = document.getElementById('warehouse').value;
            const status = document.getElementById('stockStatus').value;

            let url = '/erp/api/reports/inventory?';
            const params = [];
            if (warehouse) params.push('warehouse=' + warehouse);
            if (status) params.push('status=' + status);

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

            document.getElementById('totalItems').textContent = data.totalItems || 0;
            document.getElementById('totalValue').textContent = formatCurrency(data.totalValue || 0);
            document.getElementById('lowStockItems').textContent = data.lowStockCount || 0;
            document.getElementById('avgTurnover').textContent = (data.avgTurnover || 0).toFixed(1) + ' days';

            displayInventoryLevels(data.items || []);
            loadCharts(data);
        }

        function displayInventoryLevels(items) {
            const tbody = document.getElementById('inventoryList');
            tbody.innerHTML = '';

            if (!items || items.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8">No items found</td></tr>';
                return;
            }

            items.forEach(item => {
                const tr = document.createElement('tr');
                const totalValue = (item.quantiteCourante || 0) * (item.prixUnitaire || 0);
                let statusClass = 'success';
                let statusText = 'Optimal';
                
                if (item.quantiteCourante < item.quantiteMin) {
                    statusClass = 'danger';
                    statusText = 'Low Stock';
                } else if (item.quantiteCourante > item.quantiteMax) {
                    statusClass = 'warning';
                    statusText = 'Excess';
                }

                const status = `<span class="badge badge-${statusClass}">${statusText}</span>`;

                tr.innerHTML = `
                    <td>${item.codeArticle}</td>
                    <td>${item.libelle}</td>
                    <td>${item.entrepotLibelle}</td>
                    <td>${item.quantiteCourante}</td>
                    <td>${item.quantiteMin}</td>
                    <td>${formatCurrency(item.prixUnitaire)}</td>
                    <td>${formatCurrency(totalValue)}</td>
                    <td>${status}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts(data) {
            // Inventory by Warehouse
            const warehouses = {};
            const values = {};
            
            (data.items || []).forEach(item => {
                const wh = item.entrepotLibelle;
                warehouses[wh] = (warehouses[wh] || 0) + item.quantiteCourante;
                values[wh] = (values[wh] || 0) + ((item.quantiteCourante || 0) * (item.prixUnitaire || 0));
            });

            Dashboard.createChart('inventoryByWarehouse', 'bar', {
                labels: Object.keys(warehouses),
                datasets: [{
                    label: 'Units in Stock',
                    data: Object.values(warehouses),
                    backgroundColor: '#007bff'
                }]
            });

            // Stock Status Distribution
            const lowStock = (data.items || []).filter(i => i.quantiteCourante < i.quantiteMin).length;
            const optimal = (data.items || []).filter(i => i.quantiteCourante >= i.quantiteMin && i.quantiteCourante <= i.quantiteMax).length;
            const excess = (data.items || []).filter(i => i.quantiteCourante > i.quantiteMax).length;

            Dashboard.createChart('stockStatusChart', 'doughnut', {
                labels: ['Optimal', 'Low Stock', 'Excess'],
                datasets: [{
                    data: [optimal, lowStock, excess],
                    backgroundColor: ['#28a745', '#dc3545', '#ffc107']
                }]
            });
        }

        function refreshReport() {
            generateReport();
        }

        function exportReport() {
            const table = document.getElementById('inventoryTable');
            const csv = convertTableToCSV(table);
            downloadCSV(csv, 'inventory-report.csv');
        }

        function convertTableToCSV(table) {
            const rows = [];
            const headers = Array.from(table.querySelectorAll('th')).map(h => h.textContent);
            rows.push(headers.join(','));

            table.querySelectorAll('tbody tr').forEach(tr => {
                const cells = Array.from(tr.querySelectorAll('td')).map(td => '"' + td.textContent.trim() + '"');
                rows.push(cells.join(','));
            });

            return rows.join('\n');
        }

        function downloadCSV(csv, filename) {
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            a.click();
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
