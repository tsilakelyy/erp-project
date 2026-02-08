<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport ventes - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Rapport d'analyse des ventes</h1>
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
                    <label>Client</label>
                    <select id="customer" onchange="refreshReport()">
                        <option value="">Tous les clients</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Statut</label>
                    <select id="status" onchange="refreshReport()">
                        <option value="">Tous</option>
                        <option value="BROUILLON">Brouillon</option>
                        <option value="EN_COURS">En cours</option>
                        <option value="EN_ATTENTE">En attente</option>
                        <option value="VALIDEE">Validee</option>
                        <option value="LIVREE">Livree</option>
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
                        <div class="metric-label">Chiffre d'affaires</div>
                        <div class="metric-value" id="totalRevenue">0 Ar</div>
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
                <div class="report-bars" id="salesStatusBars"></div>
            </div>

            <div class="report-section">
                <h3>Top clients</h3>
                <div class="report-bars" id="salesCustomerBars"></div>
            </div>

            <div class="data-section">
                <h3>Detail des commandes</h3>
                <table class="table table-striped" id="ordersTable">
                    <thead>
                        <tr>
                            <th>Commande #</th>
                            <th>Client</th>
                            <th>Date commande</th>
                            <th>Date livraison</th>
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
            const customer = document.getElementById('customer').value;
            const status = document.getElementById('status').value;

            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            let url = base + '/api/reports/sales';
            const params = [];
            if (dateFrom) params.push('from=' + dateFrom);
            if (dateTo) params.push('to=' + dateTo);
            if (customer) params.push('customer=' + customer);
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
            document.getElementById('totalRevenue').textContent = formatCurrency(data.totalAmount || 0);
            document.getElementById('avgOrder').textContent = formatCurrency(data.avgOrderValue || 0);
            document.getElementById('pendingDelivery').textContent = data.pendingOrders || 0;

            populateCustomerFilter(data.customers || []);
            displayOrders(data.orders || []);
            renderStatusBars(data.statusSummary || {}, data.totalOrders || 0);
            renderCustomerBars(data.customers || [], data.totalOrders || 0);
        }

        function populateCustomerFilter(customers) {
            const select = document.getElementById('customer');
            const current = select.value;
            select.innerHTML = '<option value="">Tous les clients</option>';
            customers.forEach(customer => {
                const option = document.createElement('option');
                option.value = customer.id;
                option.textContent = customer.label || customer.id;
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
            ReportBars.render(document.getElementById('salesStatusBars'), items);
        }

        function renderCustomerBars(customers, total) {
            const items = (customers || []).slice(0, 6).map(c => ({
                label: c.label || ('ID ' + c.id),
                value: percent(c.count || 0, total),
                note: (c.count || 0) + ' cmd',
                tone: 'info'
            }));
            ReportBars.render(document.getElementById('salesCustomerBars'), items);
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
                const delivery = order.dateLivraison ? new Date(order.dateLivraison).toLocaleDateString() : '-';

                tr.innerHTML =
                    '<td>' + (order.numero || '-') + '</td>' +
                    '<td>' + (order.clientLibelle || '-') + '</td>' +
                    '<td>' + creation + '</td>' +
                    '<td>' + delivery + '</td>' +
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
            if (value.includes('LIVREE') || value.includes('VALID')) return 'success';
            if (value.includes('ATTENTE') || value.includes('BROUILLON')) return 'warning';
            if (value.includes('REJET') || value.includes('ANNULEE')) return 'danger';
            return 'info';
        }

        function refreshReport() {
            generateReport();
        }

        function exportExcel() {
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            window.location.href = base + '/api/reports/sales.xlsx';
        }
    </script>
</body>
</html>
