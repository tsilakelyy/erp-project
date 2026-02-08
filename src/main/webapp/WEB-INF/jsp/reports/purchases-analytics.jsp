<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport achats - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Rapport d'analyse des achats</h1>
                <div>
                    <button class="btn btn-primary" onclick="generateReport()">Mettre a jour</button>
                    <button class="btn btn-secondary" onclick="exportExcel()">Exporter Excel</button>
                </div>
            </div>

            <div class="filters">
                <div class="filter-group">
                    <label>Date de</label>
                    <input type="date" id="dateFrom" onchange="refreshReport()">
                </div>
                <div class="filter-group">
                    <label>Date a</label>
                    <input type="date" id="dateTo" onchange="refreshReport()">
                </div>
                <div class="filter-group">
                    <label>Fournisseur</label>
                    <select id="supplier" onchange="refreshReport()">
                        <option value="">Tous les fournisseurs</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Statut</label>
                    <select id="status" onchange="refreshReport()">
                        <option value="">Tous</option>
                        <option value="BROUILLON">Brouillon</option>
                        <option value="EN_ATTENTE">En attente</option>
                        <option value="EN_COURS">En cours</option>
                        <option value="VALIDEE">Validee</option>
                        <option value="RECUE">Recue</option>
                        <option value="FACTUREE">Facturee</option>
                    </select>
                </div>
            </div>

            <div class="report-section">
                <h3>Indicateurs cles</h3>
                <div class="metrics-grid">
                    <div class="metric-box">
                        <div class="metric-label">Total commandes</div>
                        <div class="metric-value" id="totalOrders">0</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Montant total</div>
                        <div class="metric-value" id="totalAmount">0 Ar</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Panier moyen</div>
                        <div class="metric-value" id="avgOrder">0 Ar</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">En attente</div>
                        <div class="metric-value" id="pendingDelivery">0</div>
                    </div>
                </div>
            </div>

            <div class="report-section">
                <h3>Progression globale</h3>
                <div class="report-bars" id="purchaseStatusBars"></div>
            </div>

            <div class="report-section">
                <h3>Top fournisseurs</h3>
                <div class="report-bars" id="purchaseSupplierBars"></div>
            </div>

            <div class="data-section">
                <h3>Detail des commandes</h3>
                <table class="table table-striped" id="ordersTable">
                    <thead>
                        <tr>
                            <th>Commande #</th>
                            <th>Fournisseur</th>
                            <th>Date commande</th>
                            <th>Livraison prevue</th>
                            <th>Montant</th>
                            <th>Statut</th>
                        </tr>
                    </thead>
                    <tbody id="ordersList">
                        <tr><td colspan="6">Chargement...</td></tr>
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
            generateReport();
        });

        function generateReport() {
            const dateFrom = document.getElementById('dateFrom').value;
            const dateTo = document.getElementById('dateTo').value;
            const supplier = document.getElementById('supplier').value;
            const status = document.getElementById('status').value;

            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            let url = base + '/api/reports/purchases';
            const params = [];
            if (dateFrom) params.push('from=' + dateFrom);
            if (dateTo) params.push('to=' + dateTo);
            if (supplier) params.push('supplier=' + supplier);
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

            document.getElementById('totalOrders').textContent = data.totalOrders || 0;
            document.getElementById('totalAmount').textContent = formatCurrency(data.totalAmount || 0);
            document.getElementById('avgOrder').textContent = formatCurrency(data.avgOrderValue || 0);
            document.getElementById('pendingDelivery').textContent = data.pendingOrders || 0;

            populateSupplierFilter(data.suppliers || []);
            displayOrders(data.orders || []);
            renderStatusBars(data.statusSummary || {}, data.totalOrders || 0);
            renderSupplierBars(data.suppliers || [], data.totalOrders || 0);
        }

        function populateSupplierFilter(suppliers) {
            const select = document.getElementById('supplier');
            const current = select.value;
            select.innerHTML = '<option value="">Tous les fournisseurs</option>';
            suppliers.forEach(supplier => {
                const option = document.createElement('option');
                option.value = supplier.id;
                option.textContent = supplier.label || supplier.id;
                select.appendChild(option);
            });
            select.value = current;
        }

        function renderStatusBars(summary, total) {
            const items = Object.keys(summary || {}).map(key => {
                const count = summary[key] || 0;
                return {
                    label: key,
                    value: percent(count, total),
                    note: count + ' commandes',
                    tone: toneForStatus(key)
                };
            });
            ReportBars.render(document.getElementById('purchaseStatusBars'), items);
        }

        function renderSupplierBars(suppliers, total) {
            const items = (suppliers || []).slice(0, 6).map(s => ({
                label: s.label || ('ID ' + s.id),
                value: percent(s.count || 0, total),
                note: (s.count || 0) + ' cmd',
                tone: 'info'
            }));
            ReportBars.render(document.getElementById('purchaseSupplierBars'), items);
        }

        function displayOrders(orders) {
            const tbody = document.getElementById('ordersList');
            tbody.innerHTML = '';

            if (!orders || orders.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">Aucune commande</td></tr>';
                return;
            }

            orders.forEach(order => {
                const tr = document.createElement('tr');
                const creation = order.dateCreation ? new Date(order.dateCreation).toLocaleDateString() : '-';
                const expected = order.dateExpectedDelivery ? new Date(order.dateExpectedDelivery).toLocaleDateString() : '-';

                tr.innerHTML =
                    '<td>' + (order.numero || '-') + '</td>' +
                    '<td>' + (order.fournisseurLibelle || '-') + '</td>' +
                    '<td>' + creation + '</td>' +
                    '<td>' + expected + '</td>' +
                    '<td>' + formatCurrency(order.montantTotal) + '</td>' +
                    '<td>' + (order.statut || '-') + '</td>';
                tbody.appendChild(tr);
            });
        }

        function percent(part, total) {
            if (!total) return 0;
            return Math.round((part * 100) / total);
        }

        function toneForStatus(status) {
            const value = (status || '').toUpperCase();
            if (value.includes('VALID') || value.includes('RECUE') || value.includes('FACTURE')) return 'success';
            if (value.includes('ATTENTE') || value.includes('BROUILLON')) return 'warning';
            if (value.includes('REJET') || value.includes('ANNULEE')) return 'danger';
            return 'info';
        }

        function refreshReport() {
            generateReport();
        }

        function exportExcel() {
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            window.location.href = base + '/api/reports/purchases.xlsx';
        }
    </script>
</body>
</html>
