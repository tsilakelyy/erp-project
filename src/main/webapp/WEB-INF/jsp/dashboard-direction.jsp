<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - Direction - ERP</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <style>
        .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .kpi-card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .kpi-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
        .kpi-name { font-size: 14px; color: #666; font-weight: 500; }
        .kpi-value { font-size: 28px; font-weight: bold; color: #333; margin: 10px 0; }
        .kpi-unit { font-size: 12px; color: #999; }
        .kpi-trend { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; display: inline-block; margin-top: 5px; }
        .kpi-trend.increasing { background: #d4edda; color: #155724; }
        .kpi-trend.decreasing { background: #f8d7da; color: #721c24; }
        .kpi-trend.stable { background: #e2e3e5; color: #383d41; }
        .section-title { font-size: 18px; font-weight: bold; margin-top: 30px; margin-bottom: 15px; color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
        .no-kpis { text-align: center; color: #999; padding: 40px; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Tableau de bord Direction Générale / Comité de Direction</h1>
                <p style="color: #666; margin-top: 5px;">KPIs stratégiques pour le pilotage général</p>
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
                    <button class="btn btn-secondary" type="button" onclick="resetFilters()">Réinitialiser</button>
                </div>
            </div>

            <c:if test="${empty kpis}">
                <div class="no-kpis">
                    <p>Aucun KPI disponible pour l'instant.</p>
                </div>
            </c:if>

            <c:if test="${not empty kpis}">
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="kpi">
                        <div class="kpi-card">
                            <div class="kpi-header">
                                <div class="kpi-name">${kpi.value.kpiName}</div>
                            </div>
                            <div class="kpi-value">
                                <c:choose>
                                    <c:when test="${kpi.value.unit eq '€'}">
                                        <c:out value="${kpi.value.value}" /> €
                                    </c:when>
                                    <c:when test="${kpi.value.unit eq '%'}">
                                        <c:out value="${kpi.value.value}" /> %
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${kpi.value.value}" /> <span class="kpi-unit">${kpi.value.unit}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 10px;">
                                <span class="kpi-trend ${kpi.value.trend}">${kpi.value.trend}</span>
                                <span style="font-size: 11px; color: #999;">Cible: ${kpi.value.target}</span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <div class="kpi-card">
                    <div class="kpi-label">Benefice net</div>
                    <div class="kpi-value" id="netProfit">0 Ar</div>
                    <div class="kpi-trend trend-up">+22%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Marge</div>
                    <div class="kpi-value" id="profitMargin">0%</div>
                    <div class="kpi-unit">Objectif: 25%</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Revenus vs depenses</h3>
                    <canvas id="revenueVsExpenses"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Ventes vs achats</h3>
                    <canvas id="salesVsPurchases"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Performance globale</h3>
                    <canvas id="performanceIndex"></canvas>
                </div>
            </div>

            <div class="summary-section">
                <h3>Resume des indicateurs</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Indicateur</th>
                            <th>Actuel</th>
                            <th>Precedent</th>
                            <th>Evolution</th>
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

        function buildFilterParams() {
            const from = document.getElementById('filterFrom').value;
            const to = document.getElementById('filterTo').value;
            const params = [];
            if (from) params.push('from=' + from);
            if (to) params.push('to=' + to);
            return params.join('&');
        }

        function applyFilters() {
            loadExecutiveDashboard();
        }

        function resetFilters() {
            document.getElementById('filterFrom').value = '';
            document.getElementById('filterTo').value = '';
            loadExecutiveDashboard();
        }

        function loadExecutiveDashboard() {
            loadExecutiveMetrics();
            loadPerformanceData();
            loadCharts();
        }

        function loadExecutiveMetrics() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/kpis/DIRECTION' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
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
                function() { console.error('Failed to load KPIs'); }
            );
        }

        function loadPerformanceData() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/reports/performance' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const data = response.data || response;
                    displayMetricsTable(Array.isArray(data) ? data : []);
                },
                function() { console.error('Failed to load performance data'); }
            );
        }

        function displayMetricsTable(data) {
            const tbody = document.getElementById('metricsTable');
            tbody.innerHTML = '';

            if (!data || data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4">Aucune donnee</td></tr>';
                return;
            }

            data.forEach(m => {
                const change = (m.current || 0) - (m.previous || 0);
                const base = (m.previous || 0) === 0 ? 1 : m.previous;
                const changePercent = ((change / base) * 100).toFixed(1);
                const changeClass = change >= 0 ? 'trend-up' : 'trend-down';
                const tr = document.createElement('tr');

                tr.innerHTML = `
                    <td>\${m.name}</td>
                    <td>\${m.current}</td>
                    <td>\${m.previous}</td>
                    <td><span class="\${changeClass}">\${change > 0 ? '+' : ''}\${change} (\${changePercent}%)</span></td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/charts/executive' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const data = response.data || response || {};
                    const revenue = data.revenue || { labels: [], data: [] };
                    const expenses = data.expenses || { labels: [], data: [] };
                    const sales = data.sales || { labels: [], data: [] };
                    const purchases = data.purchases || { labels: [], data: [] };
                    const performance = data.performance || { labels: [], data: [] };

                    Dashboard.createChart('revenueVsExpenses', 'bar', {
                        labels: revenue.labels,
                        datasets: [
                            { label: 'Revenus (Ar)', data: revenue.data, backgroundColor: '#28a745' },
                            { label: 'Depenses (Ar)', data: expenses.data, backgroundColor: '#dc3545' }
                        ]
                    });

                    Dashboard.createChart('salesVsPurchases', 'line', {
                        labels: sales.labels,
                        datasets: [
                            { label: 'Ventes (Ar)', data: sales.data, borderColor: '#28a745', fill: false },
                            { label: 'Achats (Ar)', data: purchases.data, borderColor: '#dc3545', fill: false }
                        ]
                    });

                    Dashboard.createChart('performanceIndex', 'radar', {
                        labels: performance.labels,
                        datasets: [{
                            label: 'Indice',
                            data: performance.data,
                            borderColor: '#007bff',
                            backgroundColor: 'rgba(0, 123, 255, 0.2)'
                        }]
                    });
                },
                function() { console.error('Erreur chargement des graphiques'); }
            );
        }

        function formatCurrency(amount) {
            return new Intl.NumberFormat('fr-MG', {
                style: 'currency',
                currency: 'MGA'
            }).format(amount);
        }
    </script>
</body>
</html>
