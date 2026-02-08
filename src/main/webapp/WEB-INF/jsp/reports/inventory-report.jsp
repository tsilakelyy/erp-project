<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport inventaire - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Rapport d'etat des stocks</h1>
                <div>
                    <button class="btn btn-primary" onclick="generateReport()">Mettre a jour</button>
                    <button class="btn btn-secondary" onclick="exportExcel()">Exporter Excel</button>
                </div>
            </div>

            <div class="filters">
                <div class="filter-group">
                    <label>Entrepot</label>
                    <select id="warehouse" onchange="refreshReport()">
                        <option value="">Tous les entrepots</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Statut du stock</label>
                    <select id="stockStatus" onchange="refreshReport()">
                        <option value="">Tous les statuts</option>
                        <option value="LOW">Stock faible</option>
                        <option value="OPTIMAL">Optimal</option>
                        <option value="EXCESS">Surstock</option>
                    </select>
                </div>
            </div>

            <div class="report-section">
                <h3>Resume inventaire</h3>
                <div class="metrics-grid">
                    <div class="metric-box">
                        <div class="metric-label">Total articles</div>
                        <div class="metric-value" id="totalItems">0</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Valeur totale</div>
                        <div class="metric-value" id="totalValue">0 Ar</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Stock faible</div>
                        <div class="metric-value" id="lowStockItems">0</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Rotation moyenne</div>
                        <div class="metric-value" id="avgTurnover">0 jours</div>
                    </div>
                </div>
            </div>

            <div class="report-section">
                <h3>Progression globale</h3>
                <div class="report-bars" id="inventoryStatusBars"></div>
            </div>

            <div class="data-section">
                <h3>Detail des stocks</h3>
                <table class="table table-striped" id="inventoryTable">
                    <thead>
                        <tr>
                            <th>Code article</th>
                            <th>Description</th>
                            <th>Entrepot</th>
                            <th>Stock actuel</th>
                            <th>Seuil minimum</th>
                            <th>Valeur unitaire</th>
                            <th>Valeur totale</th>
                            <th>Statut</th>
                        </tr>
                    </thead>
                    <tbody id="inventoryList">
                        <tr><td colspan="8">Chargement...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script src="<c:url value='/assets/js/report-bars.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadWarehouses();
            generateReport();
        });

        function loadWarehouses() {
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            ajaxCall(base + '/api/warehouses', 'GET', null,
                function(response) {
                    const warehouses = response.data || response;
                    populateWarehouseFilter(warehouses);
                },
                function() { console.error('Chargement des entrepots impossible'); }
            );
        }

        function populateWarehouseFilter(warehouses) {
            const select = document.getElementById('warehouse');
            const current = select.value;
            select.innerHTML = '<option value="">Tous les entrepots</option>';
            (warehouses || []).forEach(warehouse => {
                const option = document.createElement('option');
                option.value = warehouse.id;
                option.textContent = warehouse.nomDepot || warehouse.code || warehouse.id;
                select.appendChild(option);
            });
            select.value = current;
        }

        function generateReport() {
            const warehouse = document.getElementById('warehouse').value;
            const status = document.getElementById('stockStatus').value;

            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            let url = base + '/api/reports/inventory';
            const params = [];
            if (warehouse) params.push('warehouse=' + warehouse);
            if (status) params.push('status=' + status);

            const fullUrl = params.length ? (url + '?' + params.join('&')) : url;
            ajaxCall(fullUrl, 'GET', null,
                function(response) {
                    const data = response.data || response;
                    displayReportData(data);
                },
                function() { showError('Echec de generation du rapport'); }
            );
        }

        function displayReportData(data) {
            if (!data) return;

            document.getElementById('totalItems').textContent = data.totalItems || 0;
            document.getElementById('totalValue').textContent = formatCurrency(data.totalValue || 0);
            document.getElementById('lowStockItems').textContent = data.lowStockCount || 0;
            document.getElementById('avgTurnover').textContent = (data.avgTurnover || 0).toFixed(1) + ' jours';

            displayInventoryLevels(data.items || []);
            renderStatusBars(data.statusSummary || {}, data.totalItems || 0);
        }

        function renderStatusBars(summary, total) {
            const items = Object.keys(summary || {}).map(key => {
                const count = summary[key] || 0;
                return {
                    label: key,
                    value: percent(count, total),
                    note: count + ' articles',
                    tone: toneForStatus(key)
                };
            });
            ReportBars.render(document.getElementById('inventoryStatusBars'), items);
        }

        function displayInventoryLevels(items) {
            const tbody = document.getElementById('inventoryList');
            tbody.innerHTML = '';

            if (!items || items.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8">Aucun article</td></tr>';
                return;
            }

            items.forEach(item => {
                const tr = document.createElement('tr');
                const totalValue = (item.quantiteCourante || 0) * (item.prixUnitaire || 0);
                let statusClass = 'success';
                let statusText = 'Optimal';

                if (item.quantiteCourante < item.quantiteMin) {
                    statusClass = 'danger';
                    statusText = 'Stock faible';
                } else if (item.quantiteCourante > item.quantiteMax) {
                    statusClass = 'warning';
                    statusText = 'Surstock';
                }

                tr.innerHTML =
                    '<td>' + (item.codeArticle || '-') + '</td>' +
                    '<td>' + (item.libelle || '-') + '</td>' +
                    '<td>' + (item.entrepotLibelle || '-') + '</td>' +
                    '<td>' + (item.quantiteCourante || 0) + '</td>' +
                    '<td>' + (item.quantiteMin || 0) + '</td>' +
                    '<td>' + formatCurrency(item.prixUnitaire) + '</td>' +
                    '<td>' + formatCurrency(totalValue) + '</td>' +
                    '<td><span class="badge badge-' + statusClass + '">' + statusText + '</span></td>';
                tbody.appendChild(tr);
            });
        }

        function percent(part, total) {
            if (!total) return 0;
            return Math.round((part * 100) / total);
        }

        function toneForStatus(status) {
            const value = (status || '').toUpperCase();
            if (value.includes('LOW')) return 'danger';
            if (value.includes('EXCESS')) return 'warning';
            return 'success';
        }

        function refreshReport() {
            generateReport();
        }

        function exportExcel() {
            const wh = document.getElementById('warehouse').value;
            const status = document.getElementById('stockStatus').value;
            const params = [];
            if (wh) params.push('warehouse=' + encodeURIComponent(wh));
            if (status) params.push('status=' + encodeURIComponent(status));
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            const url = base + '/api/reports/inventory.xlsx' + (params.length ? ('?' + params.join('&')) : '');
            window.location.href = url;
        }
    </script>
</body>
</html>
