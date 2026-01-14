<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Finance - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Finance Dashboard</h1>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Total Revenue</div>
                    <div class="kpi-value" id="totalRevenue">0.00€</div>
                    <div class="kpi-trend trend-up">+12%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Total Expenses</div>
                    <div class="kpi-value" id="totalExpenses">0.00€</div>
                    <div class="kpi-trend trend-down">-5%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Profit Margin</div>
                    <div class="kpi-value" id="profitMargin">0%</div>
                    <div class="kpi-trend trend-up">+3%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Outstanding Invoices</div>
                    <div class="kpi-value" id="outstandingInvoices">0</div>
                    <div class="kpi-unit">Amount pending</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Revenue vs Expenses</h3>
                    <canvas id="revenueChart"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Cash Flow</h3>
                    <canvas id="cashFlowChart"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Payment Status</h3>
                    <canvas id="paymentStatusChart"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Recent Invoices</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Invoice #</th>
                            <th>Customer</th>
                            <th>Amount</th>
                            <th>Due Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="recentInvoices">
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
            loadFinanceDashboard();
        });

        function loadFinanceDashboard() {
            Dashboard.loadKPIs('FINANCE', 'kpisContainer');
            loadInvoiceMetrics();
            loadRecentInvoices();
            loadCharts();
        }

        function loadInvoiceMetrics() {
            ajaxCall('/erp/api/invoices/metrics', 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('totalRevenue').textContent = formatCurrency(metrics.totalRevenue || 0);
                    document.getElementById('totalExpenses').textContent = formatCurrency(metrics.totalExpenses || 0);
                    document.getElementById('profitMargin').textContent = (metrics.profitMargin || 0) + '%';
                    document.getElementById('outstandingInvoices').textContent = formatCurrency(metrics.outstanding || 0);
                },
                function(error) { console.error('Failed to load metrics'); }
            );
        }

        function loadRecentInvoices() {
            ajaxCall('/erp/api/invoices?size=5&sort=dateCreation,desc', 'GET', null,
                function(response) {
                    const invoices = response.data || response;
                    displayRecentInvoices(invoices);
                },
                function(error) { console.error('Failed to load invoices'); }
            );
        }

        function displayRecentInvoices(invoices) {
            const tbody = document.getElementById('recentInvoices');
            tbody.innerHTML = '';

            if (!invoices || invoices.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5">No invoices</td></tr>';
                return;
            }

            invoices.forEach(inv => {
                const tr = document.createElement('tr');
                const status = `<span class="badge badge-${inv.statut === 'PAID' ? 'success' : 'warning'}">${inv.statut}</span>`;

                tr.innerHTML = `
                    <td>${inv.numero}</td>
                    <td>${inv.clientLibelle || '-'}</td>
                    <td>${formatCurrency(inv.montantTotal || 0)}</td>
                    <td>${new Date(inv.dateLimite).toLocaleDateString()}</td>
                    <td>${status}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts() {
            // Revenue vs Expenses
            Dashboard.createChart('revenueChart', 'bar', {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [
                    {
                        label: 'Revenue',
                        data: [65000, 72000, 68000, 85000, 92000, 98000],
                        backgroundColor: '#28a745'
                    },
                    {
                        label: 'Expenses',
                        data: [45000, 48000, 50000, 52000, 55000, 58000],
                        backgroundColor: '#dc3545'
                    }
                ]
            });

            // Cash Flow
            Dashboard.createChart('cashFlowChart', 'line', {
                labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                datasets: [{
                    label: 'Cash Flow',
                    data: [20000, 35000, 30000, 45000],
                    borderColor: '#007bff',
                    fill: false
                }]
            });

            // Payment Status
            Dashboard.createChart('paymentStatusChart', 'doughnut', {
                labels: ['Paid', 'Pending', 'Overdue'],
                datasets: [{
                    data: [60, 25, 15],
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
