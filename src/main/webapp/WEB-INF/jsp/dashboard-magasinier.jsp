<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - Magasin - ERP</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Tableau de bord Stock</h1>
            </div>

            <div class="filters">
                <div class="filter-group">
                    <label>Entrepot</label>
                    <select id="filterWarehouse"></select>
                </div>
                <div class="filter-group">
                    <label>Statut stock</label>
                    <select id="filterStockStatus">
                        <option value="">Tous</option>
                        <option value="LOW">Stock faible</option>
                        <option value="OPTIMAL">Optimal</option>
                        <option value="EXCESS">Surstock</option>
                    </select>
                </div>
                <div class="filter-actions">
                    <button class="btn btn-secondary" type="button" onclick="applyFilters()">Appliquer</button>
                    <button class="btn btn-secondary" type="button" onclick="resetFilters()">Reinitialiser</button>
                </div>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Articles en stock</div>
                    <div class="kpi-value" id="itemsCount">0</div>
                    <div class="kpi-unit">Articles</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Taux d'occupation</div>
                    <div class="kpi-value" id="capacityUsage">0%</div>
                    <div class="kpi-trend trend-up">+5%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Articles critiques</div>
                    <div class="kpi-value" id="lowStockCount">0</div>
                    <div class="kpi-unit">A reapprovisionner</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Commandes en attente</div>
                    <div class="kpi-value" id="pendingOrders">0</div>
                    <div class="kpi-unit">A recevoir</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Stock par entrepot</h3>
                    <canvas id="stockByWarehouse"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Capacite par entrepot</h3>
                    <canvas id="capacityChart"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Tendance des mouvements</h3>
                    <canvas id="movementTrendChart"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Articles en dessous du seuil</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Code article</th>
                            <th>Description</th>
                            <th>Stock actuel</th>
                            <th>Seuil minimum</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="lowStockTable">
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
            loadWarehouseOptions();
            loadWarehouseDashboard();
        });

        function buildFilterParams() {
            const warehouse = document.getElementById('filterWarehouse').value;
            const status = document.getElementById('filterStockStatus').value;
            const params = [];
            if (warehouse) params.push('warehouse=' + warehouse);
            if (status) params.push('status=' + status);
            return params.join('&');
        }

        function applyFilters() {
            loadWarehouseDashboard();
        }

        function resetFilters() {
            document.getElementById('filterWarehouse').value = '';
            document.getElementById('filterStockStatus').value = '';
            loadWarehouseDashboard();
        }

        function loadWarehouseOptions() {
            const select = document.getElementById('filterWarehouse');
            select.innerHTML = '<option value=\"\">Tous les entrepots</option>';
            ajaxCall('/erp-system/api/warehouses', 'GET', null,
                function(response) {
                    const warehouses = response.data || response;
                    (warehouses || []).forEach(wh => {
                        const option = document.createElement('option');
                        option.value = wh.id;
                        option.textContent = wh.nomDepot || wh.code || wh.id;
                        select.appendChild(option);
                    });
                },
                function() { console.error('Chargement des entrepots impossible'); }
            );
        }

        function loadWarehouseDashboard() {
            loadStockMetrics();
            loadLowStockItems();
            loadCharts();
        }

        function loadStockMetrics() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/stock-levels/metrics' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('itemsCount').textContent = metrics.itemsCount || 0;
                    document.getElementById('capacityUsage').textContent = (metrics.capacityUsage || 0) + '%';
                    document.getElementById('lowStockCount').textContent = metrics.lowStockCount || 0;
                    document.getElementById('pendingOrders').textContent = metrics.pendingOrders || 0;
                },
                function() { console.error('Failed to load metrics'); }
            );
        }

        function loadLowStockItems() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/stock-levels/low-stock' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const items = response.data || response;
                    displayLowStockItems(items);
                },
                function() { console.error('Failed to load low stock items'); }
            );
        }

        function displayLowStockItems(items) {
            const tbody = document.getElementById('lowStockTable');
            tbody.innerHTML = '';

            if (!items || items.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5">Aucun article critique</td></tr>';
                return;
            }

            items.slice(0, 10).forEach(item => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>\${item.codeArticle}</td>
                    <td>\${item.libelle}</td>
                    <td>\${item.quantiteCourante}</td>
                    <td>\${item.quantiteMin}</td>
                    <td>
                        <button class="btn btn-sm btn-primary" onclick="orderMore('\${item.codeArticle}')">Commander</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function orderMore(code) {
            showSuccess('Commande d\'achat preparee pour ' + code);
            window.location.href = '/erp-system/purchases/orders/new?article=' + code;
        }

        function loadCharts() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/stock-levels/charts' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const data = response.data || response || {};
                    const stockByWarehouse = data.stockByWarehouse || { labels: [], data: [] };
                    const capacityUsage = data.capacityUsage || { labels: [], data: [] };
                    const movement = data.movementTrend || { labels: [], inbound: [], outbound: [] };

                    Dashboard.createChart('stockByWarehouse', 'bar', {
                        labels: stockByWarehouse.labels,
                        datasets: [{
                            label: 'Quantite',
                            data: stockByWarehouse.data,
                            backgroundColor: '#007bff'
                        }]
                    });

                    Dashboard.createChart('capacityChart', 'bar', {
                        labels: capacityUsage.labels,
                        datasets: [{
                            label: 'Occupation %',
                            data: capacityUsage.data,
                            backgroundColor: '#17a2b8'
                        }]
                    });

                    Dashboard.createChart('movementTrendChart', 'line', {
                        labels: movement.labels,
                        datasets: [
                            {
                                label: 'Entrees',
                                data: movement.inbound,
                                borderColor: '#28a745',
                                fill: false
                            },
                            {
                                label: 'Sorties',
                                data: movement.outbound,
                                borderColor: '#dc3545',
                                fill: false
                            }
                        ]
                    });
                },
                function() { console.error('Erreur chargement des graphiques'); }
            );
        }
    </script>
</body>
</html>
