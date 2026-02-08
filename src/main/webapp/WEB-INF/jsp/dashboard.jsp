<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ERP - Tableau de bord</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.0/dist/chart.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Tableau de bord</h1>
                <div>
                    <span>${username}</span>
                    <a href="/erp-system/logout" class="btn btn-sm btn-danger" style="margin-left: 20px;">Deconnexion</a>
                </div>
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
                    <label>Entrepot</label>
                    <select id="filterWarehouse"></select>
                </div>
                <div class="filter-actions">
                    <button class="btn btn-secondary" type="button" onclick="applyFilters()">Appliquer</button>
                    <button class="btn btn-secondary" type="button" onclick="resetFilters()">Reinitialiser</button>
                </div>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Commandes en attente</div>
                    <div class="kpi-value" id="pendingOrders">0</div>
                </div>
                <div class="kpi-card" style="border-left-color: #007bff;">
                    <div class="kpi-label">Articles en stock</div>
                    <div class="kpi-value" id="itemsCount">0</div>
                </div>
                <div class="kpi-card" style="border-left-color: #2ecc71;">
                    <div class="kpi-label">Factures en attente</div>
                    <div class="kpi-value" id="outstanding">0 Ar</div>
                </div>
                <div class="kpi-card" style="border-left-color: #f39c12;">
                    <div class="kpi-label">Marge</div>
                    <div class="kpi-value" id="profitMargin">0%</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h5>Ventes mensuelles</h5>
                    <canvas id="salesChart" style="max-height: 300px;"></canvas>
                </div>

                <div class="chart-container">
                    <h5>Mouvements de stock</h5>
                    <canvas id="stockChart" style="max-height: 300px;"></canvas>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadWarehouseOptions();
            loadMainDashboard();
        });

        function buildFilterParams() {
            const from = document.getElementById('filterFrom').value;
            const to = document.getElementById('filterTo').value;
            const warehouse = document.getElementById('filterWarehouse').value;
            const params = [];
            if (from) params.push('from=' + from);
            if (to) params.push('to=' + to);
            if (warehouse) params.push('warehouse=' + warehouse);
            return params.join('&');
        }

        function applyFilters() {
            loadMainDashboard();
        }

        function resetFilters() {
            document.getElementById('filterFrom').value = '';
            document.getElementById('filterTo').value = '';
            document.getElementById('filterWarehouse').value = '';
            loadMainDashboard();
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
                }
            );
        }

        function loadMainDashboard() {
            loadKpis();
            loadCharts();
        }

        function loadKpis() {
            const qs = buildFilterParams();
            const purchaseUrl = '/erp-system/api/purchase-orders/metrics' + (qs ? ('?' + qs) : '');
            ajaxCall(purchaseUrl, 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('pendingOrders').textContent = metrics.pendingCount || 0;
                }
            );

            const stockUrl = '/erp-system/api/stock-levels/metrics' + (qs ? ('?' + qs) : '');
            ajaxCall(stockUrl, 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('itemsCount').textContent = metrics.itemsCount || 0;
                }
            );

            const invoiceUrl = '/erp-system/api/invoices/metrics' + (qs ? ('?' + qs) : '');
            ajaxCall(invoiceUrl, 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('outstanding').textContent = formatCurrency(metrics.outstanding || 0);
                    document.getElementById('profitMargin').textContent = (metrics.profitMargin || 0) + '%';
                }
            );
        }

        function loadCharts() {
            const qs = buildFilterParams();
            const salesUrl = '/erp-system/api/charts/sales' + (qs ? ('?' + qs) : '');
            ajaxCall(salesUrl, 'GET', null,
                function(response) {
                    const data = response.data || response || {};
                    const monthly = data.monthlyRevenue || { labels: [], data: [] };

                    const salesCtx = document.getElementById('salesChart').getContext('2d');
                    new Chart(salesCtx, {
                        type: 'line',
                        data: {
                            labels: monthly.labels,
                            datasets: [{
                                label: 'Ventes (Ar)',
                                data: monthly.data,
                                borderColor: '#667eea',
                                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                                tension: 0.4
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: true,
                            plugins: {
                                legend: { display: true }
                            }
                        }
                    });
                }
            );

            const stockUrl = '/erp-system/api/stock-levels/charts' + (qs ? ('?' + qs) : '');
            ajaxCall(stockUrl, 'GET', null,
                function(response) {
                    const data = response.data || response || {};
                    const movement = data.movementTrend || { labels: [], inbound: [], outbound: [] };

                    const stockCtx = document.getElementById('stockChart').getContext('2d');
                    new Chart(stockCtx, {
                        type: 'line',
                        data: {
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
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: true
                        }
                    });
                }
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
