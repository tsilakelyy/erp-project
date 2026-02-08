<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - ERP</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Tableau de bord</h1>
            </div>

            <div class="filters">
                <div class="filter-group">
                    <label>Du</label>
                    <input type="date" id="filterFrom">
                </div>
                <div class="filter-group">
                    <label>Au</label>
                    <input type="date" id="filterTo">
                </div>
                <div class="filter-actions">
                    <button class="btn btn-secondary" type="button" onclick="applyFilters()">Appliquer</button>
                    <button class="btn btn-secondary" type="button" onclick="resetFilters()">Reinitialiser</button>
                </div>
            </div>

            <div class="dashboard-grid">
                <div id="kpisContainer" class="kpi-cards">
                    <!-- Populated by JavaScript -->
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Tendance des ventes</h3>
                    <canvas id="salesChart"></canvas>
                </div>
                <div class="chart-container">
                    <h3>Repartition du stock</h3>
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

        function buildFilterParams() {
            const from = document.getElementById('filterFrom').value;
            const to = document.getElementById('filterTo').value;
            const params = [];
            if (from) params.push('from=' + from);
            if (to) params.push('to=' + to);
            return params.join('&');
        }

        function applyFilters() {
            loadDashboardData();
        }

        function resetFilters() {
            document.getElementById('filterFrom').value = '';
            document.getElementById('filterTo').value = '';
            loadDashboardData();
        }

        function loadDashboardData() {
            const userRole = getCurrentUser()?.roles?.[0] || 'DIRECTION';
            const qs = buildFilterParams();
            const url = '/erp-system/api/kpis/' + userRole + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
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
                container.innerHTML = '<p>Aucune donnee KPI</p>';
                return;
            }

            kpis.forEach(kpi => {
                const card = document.createElement('div');
                card.className = 'kpi-card';
                card.innerHTML = `
                    <div class="kpi-label">\${kpi.libelle}</div>
                    <div class="kpi-value">\${kpi.value}</div>
                    <div class="kpi-unit">\${kpi.unit}</div>
                    <div class="kpi-trend \${kpi.trend == 'UP' ? 'trend-up' : 'trend-down'}">
                        \${kpi.trend} \${kpi.variance}%
                    </div>
                `;
                container.appendChild(card);
            });
        }

        function loadCharts() {
            const qs = buildFilterParams();

            const salesCtx = document.getElementById('salesChart');
            if (salesCtx) {
                ajaxCall('/erp-system/api/charts/sales' + (qs ? ('?' + qs) : ''), 'GET', null,
                    function(response) {
                        const data = response.data || response || {};
                        const monthly = data.monthlyRevenue || { labels: [], data: [] };
                        new Chart(salesCtx, {
                            type: 'line',
                            data: {
                                labels: monthly.labels,
                                datasets: [{
                                    label: 'Ventes (Ar)',
                                    data: monthly.data,
                                    borderColor: '#007bff',
                                    fill: false
                                }]
                            }
                        });
                    }
                );
            }

            const stockCtx = document.getElementById('stockChart');
            if (stockCtx) {
                ajaxCall('/erp-system/api/stock-levels/charts' + (qs ? ('?' + qs) : ''), 'GET', null,
                    function(response) {
                        const data = response.data || response || {};
                        const stockByWarehouse = data.stockByWarehouse || { labels: [], data: [] };
                        new Chart(stockCtx, {
                            type: 'doughnut',
                            data: {
                                labels: stockByWarehouse.labels,
                                datasets: [{
                                    data: stockByWarehouse.data,
                                    backgroundColor: ['#28a745', '#ffc107', '#dc3545', '#17a2b8']
                                }]
                            }
                        });
                    }
                );
            }
        }
    </script>
</body>
</html>


