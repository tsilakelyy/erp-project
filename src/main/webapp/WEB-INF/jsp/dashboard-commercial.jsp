<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - Ventes - ERP</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Tableau de bord Ventes</h1>
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
                <div class="filter-group">
                    <label>Statut</label>
                    <select id="filterStatus">
                        <option value="">Tous</option>
                        <option value="BROUILLON">Brouillon</option>
                        <option value="EN_COURS">En cours</option>
                        <option value="EN_ATTENTE">En attente</option>
                        <option value="VALIDEE">Validee</option>
                        <option value="LIVREE">Livree</option>
                    </select>
                </div>
                <div class="filter-actions">
                    <button class="btn btn-secondary" type="button" onclick="applyFilters()">Appliquer</button>
                    <button class="btn btn-secondary" type="button" onclick="resetFilters()">Reinitialiser</button>
                </div>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Chiffre d'affaires</div>
                    <div class="kpi-value" id="totalSales">0 Ar</div>
                    <div class="kpi-trend trend-up">+15%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Commandes du mois</div>
                    <div class="kpi-value" id="ordersCount">0</div>
                    <div class="kpi-unit">Commandes</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Commandes en attente</div>
                    <div class="kpi-value" id="pendingOrders">0</div>
                    <div class="kpi-unit">A traiter</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Panier moyen</div>
                    <div class="kpi-value" id="avgOrderValue">0 Ar</div>
                    <div class="kpi-trend trend-up">+5%</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Ventes par client</h3>
                    <canvas id="salesByCustomer"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Chiffre d'affaires mensuel</h3>
                    <canvas id="monthlyRevenue"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Statut des commandes</h3>
                    <canvas id="orderStatus"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Dernieres commandes clients</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Commande #</th>
                            <th>Client</th>
                            <th>Montant</th>
                            <th>Date</th>
                            <th>Statut</th>
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

        function buildFilterParams() {
            const from = document.getElementById('filterFrom').value;
            const to = document.getElementById('filterTo').value;
            const status = document.getElementById('filterStatus').value;
            const params = [];
            if (from) params.push('from=' + from);
            if (to) params.push('to=' + to);
            if (status) params.push('status=' + status);
            return params.join('&');
        }

        function applyFilters() {
            loadSalesDashboard();
        }

        function resetFilters() {
            document.getElementById('filterFrom').value = '';
            document.getElementById('filterTo').value = '';
            document.getElementById('filterStatus').value = '';
            loadSalesDashboard();
        }

        function loadSalesDashboard() {
            loadSalesMetrics();
            loadRecentSalesOrders();
            loadCharts();
        }

        function loadSalesMetrics() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/sales-orders/metrics' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('totalSales').textContent = formatCurrency(metrics.totalSales || 0);
                    document.getElementById('ordersCount').textContent = metrics.ordersCount || 0;
                    document.getElementById('pendingOrders').textContent = metrics.pendingOrders || 0;
                    document.getElementById('avgOrderValue').textContent = formatCurrency(metrics.avgOrderValue || 0);
                },
                function() { console.error('Failed to load metrics'); }
            );
        }

        function loadRecentSalesOrders() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/sales-orders?size=10&sort=dateCreation,desc' + (qs ? ('&' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const orders = response.data || response;
                    displayRecentSalesOrders(orders);
                },
                function() { console.error('Failed to load orders'); }
            );
        }

        function displayRecentSalesOrders(orders) {
            const tbody = document.getElementById('recentSalesOrders');
            tbody.innerHTML = '';

            if (!orders || orders.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">Aucune commande</td></tr>';
                return;
            }

            orders.forEach(order => {
                const tr = document.createElement('tr');
                const statusClass = getStatusClass(order.statut);
                const status = `<span class="badge badge-\${statusClass}">\${order.statut}</span>`;

                tr.innerHTML = `
                    <td>\${order.numero}</td>
                    <td>\${order.clientLibelle || '-'}</td>
                    <td>\${formatCurrency(order.montantTotal || 0)}</td>
                    <td>\${order.dateCreation ? new Date(order.dateCreation).toLocaleDateString() : '-'}</td>
                    <td>\${status}</td>
                    <td><a href="/erp-system/sales/orders/\${order.id}">Voir</a></td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/charts/sales' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const data = response.data || response || {};
                    const byCustomer = data.byCustomer || { labels: [], data: [] };
                    const byStatus = data.byStatus || { labels: [], data: [] };
                    const monthly = data.monthlyRevenue || { labels: [], data: [] };

                    Dashboard.createChart('salesByCustomer', 'bar', {
                        labels: byCustomer.labels,
                        datasets: [{
                            label: 'Ventes (Ar)',
                            data: byCustomer.data,
                            backgroundColor: '#28a745'
                        }]
                    });

                    Dashboard.createChart('monthlyRevenue', 'line', {
                        labels: monthly.labels,
                        datasets: [{
                            label: 'Chiffre d\'affaires (Ar)',
                            data: monthly.data,
                            borderColor: '#007bff',
                            fill: false
                        }]
                    });

                    Dashboard.createChart('orderStatus', 'doughnut', {
                        labels: byStatus.labels,
                        datasets: [{
                            data: byStatus.data,
                            backgroundColor: ['#28a745', '#ffc107', '#dc3545', '#17a2b8', '#6c757d']
                        }]
                    });
                },
                function() { console.error('Erreur chargement des graphiques'); }
            );
        }

        function getStatusClass(status) {
            if (!status) return 'secondary';
            const s = status.toUpperCase();
            if (['LIVREE', 'VALIDEE'].includes(s)) return 'success';
            if (['EN_COURS', 'BROUILLON', 'DRAFT', 'SUBMITTED', 'EN_ATTENTE'].includes(s)) return 'warning';
            if (['ANNULEE', 'REJETEE'].includes(s)) return 'danger';
            return 'info';
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
