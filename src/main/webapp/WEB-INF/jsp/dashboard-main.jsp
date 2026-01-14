<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Dashboard</h1>
            </div>

            <div class="dashboard-grid">
                <div id="kpisContainer" class="kpi-cards">
                    <!-- Populated by JavaScript -->
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Sales Trend</h3>
                    <canvas id="salesChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3>Stock Distribution</h3>
                    <canvas id="stockChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadDashboardData();
        });

        function loadDashboardData() {
            const userRole = getCurrentUser()?.roles?.[0] || 'DIRECTION';
            ajaxCall('/erp/api/kpis/' + userRole, 'GET', null,
                function(response) {
                    const kpis = response.data || response;
                    displayKPIs(kpis);
                    loadCharts();
                },
                function(error) { showError('Failed to load dashboard'); }
            );
        }

        function displayKPIs(kpis) {
            const container = document.getElementById('kpisContainer');
            container.innerHTML = '';

            if (!kpis || kpis.length === 0) {
                container.innerHTML = '<p>No KPI data available</p>';
                return;
            }

            kpis.forEach(kpi => {
                const card = document.createElement('div');
                card.className = 'kpi-card';
                card.innerHTML = `
                    <div class="kpi-label">${kpi.libelle}</div>
                    <div class="kpi-value">${kpi.value}</div>
                    <div class="kpi-unit">${kpi.unit}</div>
                    <div class="kpi-trend ${kpi.trend === 'UP' ? 'trend-up' : 'trend-down'}">
                        ${kpi.trend} ${kpi.variance}%
                    </div>
                `;
                container.appendChild(card);
            });
        }

        function loadCharts() {
            // Load sales chart
            const salesCtx = document.getElementById('salesChart');
            if (salesCtx) {
                new Chart(salesCtx, {
                    type: 'line',
                    data: {
                        labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                        datasets: [{
                            label: 'Sales',
                            data: [12000, 19000, 3000, 5000],
                            borderColor: '#007bff',
                            fill: false
                        }]
                    }
                });
            }

            // Load stock chart
            const stockCtx = document.getElementById('stockChart');
            if (stockCtx) {
                new Chart(stockCtx, {
                    type: 'doughnut',
                    data: {
                        labels: ['In Stock', 'Reserved', 'Low Stock'],
                        datasets: [{
                            data: [60, 25, 15],
                            backgroundColor: ['#28a745', '#ffc107', '#dc3545']
                        }]
                    }
                });
            }
        }
    </script>
</body>
</html>
