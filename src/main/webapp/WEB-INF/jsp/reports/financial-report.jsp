<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Financial Report - ERP</title>
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
                <h1>Financial Report</h1>
                <button class="btn btn-primary" onclick="generateReport()">Generate Report</button>
                <button class="btn btn-secondary" onclick="exportReport()">Export PDF</button>
            </div>

            <div class="filters">
                <div class="filter-group">
                    <label>Period:</label>
                    <select id="period" onchange="refreshReport()">
                        <option value="month">This Month</option>
                        <option value="quarter">This Quarter</option>
                        <option value="year">This Year</option>
                        <option value="custom">Custom</option>
                    </select>
                </div>
                <div class="filter-group" id="customDates" style="display:none;">
                    <label>Date From:</label>
                    <input type="date" id="dateFrom" onchange="refreshReport()">
                    <label>Date To:</label>
                    <input type="date" id="dateTo" onchange="refreshReport()">
                </div>
            </div>

            <div class="report-section">
                <h3>Financial Summary</h3>
                <div class="metrics-grid">
                    <div class="metric-box">
                        <div class="metric-label">Total Revenue</div>
                        <div class="metric-value" id="totalRevenue">0.00€</div>
                        <div class="metric-trend" id="revenueChange">+0%</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Total Expenses</div>
                        <div class="metric-value" id="totalExpenses">0.00€</div>
                        <div class="metric-trend" id="expenseChange">+0%</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Net Profit</div>
                        <div class="metric-value" id="netProfit">0.00€</div>
                        <div class="metric-trend" id="profitChange">+0%</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Profit Margin</div>
                        <div class="metric-value" id="profitMargin">0%</div>
                        <div class="metric-unit">of revenue</div>
                    </div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Revenue & Expenses Trend</h3>
                    <canvas id="trendChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3>Expense Breakdown</h3>
                    <canvas id="expenseBreakdown"></canvas>
                </div>
                <div class="chart-container">
                    <h3>Cash Flow Analysis</h3>
                    <canvas id="cashFlowChart"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Monthly Financial Summary</h3>
                <table class="table" id="financialTable">
                    <thead>
                        <tr>
                            <th>Month</th>
                            <th>Revenue</th>
                            <th>Expenses</th>
                            <th>Profit</th>
                            <th>Margin %</th>
                            <th>Cash Flow</th>
                        </tr>
                    </thead>
                    <tbody id="financialList">
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
        document.getElementById('period').addEventListener('change', function(e) {
            const customDates = document.getElementById('customDates');
            customDates.style.display = e.target.value === 'custom' ? 'flex' : 'none';
            refreshReport();
        });

        document.addEventListener('DOMContentLoaded', function() {
            generateReport();
        });

        function generateReport() {
            const period = document.getElementById('period').value;
            let url = '/erp/api/reports/financial?period=' + period;

            if (period === 'custom') {
                const dateFrom = document.getElementById('dateFrom').value;
                const dateTo = document.getElementById('dateTo').value;
                if (dateFrom && dateTo) {
                    url += '&from=' + dateFrom + '&to=' + dateTo;
                }
            }

            ajaxCall(url, 'GET', null,
                function(response) {
                    const data = response.data || response;
                    displayReportData(data);
                },
                function(error) { showError('Failed to generate report'); }
            );
        }

        function displayReportData(data) {
            if (!data) return;

            document.getElementById('totalRevenue').textContent = formatCurrency(data.totalRevenue || 0);
            document.getElementById('totalExpenses').textContent = formatCurrency(data.totalExpenses || 0);
            document.getElementById('netProfit').textContent = formatCurrency(data.netProfit || 0);
            document.getElementById('profitMargin').textContent = (data.profitMargin || 0).toFixed(1) + '%';
            
            document.getElementById('revenueChange').textContent = (data.revenueChange > 0 ? '+' : '') + data.revenueChange.toFixed(1) + '%';
            document.getElementById('expenseChange').textContent = (data.expenseChange > 0 ? '+' : '') + data.expenseChange.toFixed(1) + '%';
            document.getElementById('profitChange').textContent = (data.profitChange > 0 ? '+' : '') + data.profitChange.toFixed(1) + '%';

            displayFinancialSummary(data.monthlySummary || []);
            loadCharts(data);
        }

        function displayFinancialSummary(summary) {
            const tbody = document.getElementById('financialList');
            tbody.innerHTML = '';

            if (!summary || summary.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">No data</td></tr>';
                return;
            }

            summary.forEach(month => {
                const tr = document.createElement('tr');
                const margin = month.revenue > 0 ? ((month.profit / month.revenue) * 100).toFixed(1) : 0;

                tr.innerHTML = `
                    <td>${month.month}</td>
                    <td>${formatCurrency(month.revenue)}</td>
                    <td>${formatCurrency(month.expenses)}</td>
                    <td>${formatCurrency(month.profit)}</td>
                    <td>${margin}%</td>
                    <td>${formatCurrency(month.cashFlow)}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts(data) {
            // Trend Chart
            Dashboard.createChart('trendChart', 'line', {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [
                    {
                        label: 'Revenue',
                        data: [250000, 280000, 320000, 350000, 380000, 420000],
                        borderColor: '#28a745',
                        fill: false
                    },
                    {
                        label: 'Expenses',
                        data: [180000, 195000, 210000, 225000, 240000, 250000],
                        borderColor: '#dc3545',
                        fill: false
                    }
                ]
            });

            // Expense Breakdown
            Dashboard.createChart('expenseBreakdown', 'doughnut', {
                labels: ['Salaries', 'Operations', 'Marketing', 'Administrative', 'Other'],
                datasets: [{
                    data: [40, 25, 15, 12, 8],
                    backgroundColor: ['#007bff', '#28a745', '#ffc107', '#dc3545', '#6c757d']
                }]
            });

            // Cash Flow
            Dashboard.createChart('cashFlowChart', 'bar', {
                labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                datasets: [
                    {
                        label: 'Inflow',
                        data: [65000, 72000, 68000, 85000],
                        backgroundColor: '#28a745'
                    },
                    {
                        label: 'Outflow',
                        data: [45000, 48000, 50000, 52000],
                        backgroundColor: '#dc3545'
                    }
                ]
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

        .metric-trend {
            font-size: 12px;
            margin-top: 5px;
        }

        .metric-unit {
            font-size: 11px;
            color: #999;
            margin-top: 5px;
        }

        #customDates {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        #customDates input {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
    </style>
</body>
</html>
