<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - Achats - ERP</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Tableau de bord Achats</h1>
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
                        <option value="RECUE">Recue</option>
                    </select>
                </div>
                <div class="filter-actions">
                    <button class="btn btn-secondary" type="button" onclick="applyFilters()">Appliquer</button>
                    <button class="btn btn-secondary" type="button" onclick="resetFilters()">Reinitialiser</button>
                </div>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Total commandes d'achat</div>
                    <div class="kpi-value" id="totalOrders">0</div>
                    <div class="kpi-unit">Ce mois-ci</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Total depenses</div>
                    <div class="kpi-value" id="totalSpend">0 Ar</div>
                    <div class="kpi-trend trend-up">+8%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Commandes en attente</div>
                    <div class="kpi-value" id="pendingCount">0</div>
                    <div class="kpi-unit">En attente de livraison</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Delai moyen de livraison</div>
                    <div class="kpi-value" id="avgDelivery">0 jours</div>
                    <div class="kpi-unit">Estime</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Commandes par fournisseur</h3>
                    <canvas id="ordersBySupplier"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Repartition des statuts</h3>
                    <canvas id="statusDistribution"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Depenses mensuelles</h3>
                    <canvas id="spendingTrend"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Dernieres commandes d'achat</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Commande #</th>
                            <th>Fournisseur</th>
                            <th>Montant</th>
                            <th>Date echeance</th>
                            <th>Statut</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="recentOrders">
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
            loadPurchasingDashboard();
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
            loadPurchasingDashboard();
        }

        function resetFilters() {
            document.getElementById('filterFrom').value = '';
            document.getElementById('filterTo').value = '';
            document.getElementById('filterStatus').value = '';
            loadPurchasingDashboard();
        }

        function loadPurchasingDashboard() {
            loadPurchaseMetrics();
            loadRecentOrders();
            loadCharts();
        }

        function loadPurchaseMetrics() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/purchase-orders/metrics' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('totalOrders').textContent = metrics.totalOrders || 0;
                    document.getElementById('totalSpend').textContent = formatCurrency(metrics.totalSpend || 0);
                    document.getElementById('pendingCount').textContent = metrics.pendingCount || 0;
                    document.getElementById('avgDelivery').textContent = (metrics.avgDeliveryDays || 0) + ' jours';
                },
                function() { console.error('Failed to load metrics'); }
            );
        }

        function loadRecentOrders() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/purchase-orders?size=10&sort=dateCreation,desc' + (qs ? ('&' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const orders = response.data || response;
                    displayRecentOrders(orders);
                },
                function() { console.error('Failed to load orders'); }
            );
        }

        function displayRecentOrders(orders) {
            const tbody = document.getElementById('recentOrders');
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
                    <td>\${order.fournisseurLibelle || '-'}</td>
                    <td>\${formatCurrency(order.montantTotal || 0)}</td>
                    <td>\${order.dateExpectedDelivery ? new Date(order.dateExpectedDelivery).toLocaleDateString() : '-'}</td>
                    <td>\${status}</td>
                    <td><a href="/erp-system/purchases/orders/\${order.id}">Voir</a></td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/charts/purchases' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const data = response.data || response || {};
                    const bySupplier = data.bySupplier || { labels: [], data: [] };
                    const byStatus = data.byStatus || { labels: [], data: [] };
                    const monthly = data.monthlySpending || { labels: [], data: [] };

                    Dashboard.createChart('ordersBySupplier', 'bar', {
                        labels: bySupplier.labels,
                        datasets: [{
                            label: 'Montant (Ar)',
                            data: bySupplier.data,
                            backgroundColor: '#007bff'
                        }]
                    });

                    Dashboard.createChart('statusDistribution', 'doughnut', {
                        labels: byStatus.labels,
                        datasets: [{
                            data: byStatus.data,
                            backgroundColor: ['#28a745', '#ffc107', '#dc3545', '#17a2b8', '#6c757d']
                        }]
                    });

                    Dashboard.createChart('spendingTrend', 'line', {
                        labels: monthly.labels,
                        datasets: [{
                            label: 'Depenses mensuelles (Ar)',
                            data: monthly.data,
                            borderColor: '#007bff',
                            fill: false
                        }]
                    });
                },
                function() { console.error('Erreur chargement des graphiques'); }
            );
        }

        function getStatusClass(status) {
            if (!status) return 'secondary';
            const s = status.toUpperCase();
            if (['RECUE', 'VALIDEE', 'APPROUVEE'].includes(s)) return 'success';
            if (['EN_COURS', 'BROUILLON', 'SUBMITTED', 'DRAFT', 'EN_ATTENTE'].includes(s)) return 'warning';
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
