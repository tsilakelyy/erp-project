<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Direction - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Executive Dashboard</h1>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Total Revenue</div>
                    <div class="kpi-value" id="totalRevenue">0.00€</div>
                    <div class="kpi-trend trend-up">+18%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Total Expenses</div>
                    <div class="kpi-value" id="totalExpenses">0.00€</div>
                    <div class="kpi-trend trend-down">-3%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Net Profit</div>
                    <div class="kpi-value" id="netProfit">0.00€</div>
                    <div class="kpi-trend trend-up">+22%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Profit Margin</div>
                    <div class="kpi-value" id="profitMargin">0%</div>
                    <div class="kpi-unit">YTD Target: 25%</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Revenue vs Expenses</h3>
                    <canvas id="revenueVsExpenses"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Sales vs Purchases</h3>
                    <canvas id="salesVsPurchases"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Business Performance</h3>
                    <canvas id="performanceIndex"></canvas>
                </div>
            </div>

            <div class="summary-section">
                <h3>Key Metrics Summary</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Metric</th>
                            <th>Current</th>
                            <th>Previous</th>
                            <th>Change</th>
                        </tr>
                    </thead>
                    <tbody id="metricsTable">
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
            loadExecutiveDashboard();
        });

        function loadExecutiveDashboard() {
            loadExecutiveMetrics();
            loadPerformanceData();
            loadCharts();
        }

        function loadExecutiveMetrics() {
            ajaxCall('/erp/api/kpis/DIRECTION', 'GET', null,
                function(response) {
                    const data = response.data || response;
                    if (Array.isArray(data)) {
                        data.forEach(kpi => {
                            if (kpi.id === 'revenue') {
                                document.getElementById('totalRevenue').textContent = formatCurrency(kpi.value);
                            } else if (kpi.id === 'expenses') {
                                document.getElementById('totalExpenses').textContent = formatCurrency(kpi.value);
                            } else if (kpi.id === 'profit') {
                                document.getElementById('netProfit').textContent = formatCurrency(kpi.value);
                            } else if (kpi.id === 'margin') {
                                document.getElementById('profitMargin').textContent = kpi.value + '%';
                            }
                        });
                    }
                },
                function(error) { console.error('Failed to load KPIs'); }
            );
        }

        function loadPerformanceData() {
            ajaxCall('/erp/api/reports/performance', 'GET', null,
                function(response) {
                    const data = response.data || response;
                    displayMetricsTable(data);
                },
                function(error) { console.error('Failed to load performance data'); }
            );
        }

        function displayMetricsTable(data) {
            const tbody = document.getElementById('metricsTable');
            tbody.innerHTML = '';

            const metrics = [
                { name: 'Total Sales Orders', current: 125, previous: 110 },
                { name: 'Total Purchase Orders', current: 85, previous: 92 },
                { name: 'Inventory Turnover', current: 8.5, previous: 7.8 },
                { name: 'Customer Count', current: 42, previous: 38 },
                { name: 'Supplier Count', current: 28, previous: 28 }
            ];

            metrics.forEach(m => {
                const change = m.current - m.previous;
                const changePercent = ((change / m.previous) * 100).toFixed(1);
                const changeClass = change >= 0 ? 'trend-up' : 'trend-down';
                const tr = document.createElement('tr');

                tr.innerHTML = `
                    <td>${m.name}</td>
                    <td>${m.current}</td>
                    <td>${m.previous}</td>
                    <td><span class="${changeClass}">${change > 0 ? '+' : ''}${change} (${changePercent}%)</span></td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts() {
            // Revenue vs Expenses
            Dashboard.createChart('revenueVsExpenses', 'bar', {
                labels: ['Q1', 'Q2', 'Q3', 'Q4'],
                datasets: [
                    {
                        label: 'Revenue',
                        data: [250000, 280000, 320000, 350000],
                        backgroundColor: '#28a745'
                    },
                    {
                        label: 'Expenses',
                        data: [180000, 195000, 210000, 225000],
                        backgroundColor: '#dc3545'
                    }
                ]
            });

            // Sales vs Purchases
            Dashboard.createChart('salesVsPurchases', 'line', {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                datasets: [
                    {
                        label: 'Sales',
                        data: [85000, 92000, 78000, 105000, 98000, 115000, 125000, 120000, 135000, 142000, 155000, 168000],
                        borderColor: '#28a745',
                        fill: false
                    },
                    {
                        label: 'Purchases',
                        data: [60000, 65000, 58000, 72000, 68000, 80000, 85000, 82000, 92000, 98000, 105000, 115000],
                        borderColor: '#dc3545',
                        fill: false
                    }
                ]
            });

            // Performance Index
            Dashboard.createChart('performanceIndex', 'radar', {
                labels: ['Sales', 'Profitability', 'Efficiency', 'Growth', 'Customer Satisfaction'],
                datasets: [{
                    label: 'Performance Index',
                    data: [85, 78, 82, 90, 88],
                    borderColor: '#007bff',
                    backgroundColor: 'rgba(0, 123, 255, 0.2)'
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
