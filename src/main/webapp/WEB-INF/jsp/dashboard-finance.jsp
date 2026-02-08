<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - Finance - ERP</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Tableau de bord Finance</h1>
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
                    <label>Type</label>
                    <select id="filterType">
                        <option value="">Tous</option>
                        <option value="VENTE">Vente</option>
                        <option value="ACHAT">Achat</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Statut</label>
                    <select id="filterStatus">
                        <option value="">Tous</option>
                        <option value="PAYEE">Payee</option>
                        <option value="EN_ATTENTE">En attente</option>
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
                    <div class="kpi-value" id="totalRevenue">0 Ar</div>
                    <div class="kpi-trend trend-up">+12%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Depenses</div>
                    <div class="kpi-value" id="totalExpenses">0 Ar</div>
                    <div class="kpi-trend trend-down">-5%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Marge</div>
                    <div class="kpi-value" id="profitMargin">0%</div>
                    <div class="kpi-trend trend-up">+3%</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label">Factures en attente</div>
                    <div class="kpi-value" id="outstandingInvoices">0</div>
                    <div class="kpi-unit">Montant en attente</div>
                </div>
            </div>

            <div class="charts-section">
                <div class="chart-container">
                    <h3>Revenus vs depenses</h3>
                    <canvas id="revenueChart"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Flux de tresorerie</h3>
                    <canvas id="cashFlowChart"></canvas>
                </div>

                <div class="chart-container">
                    <h3>Statut des paiements</h3>
                    <canvas id="paymentStatusChart"></canvas>
                </div>
            </div>

            <div class="data-section">
                <h3>Dernieres factures</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Facture #</th>
                            <th>Tiers</th>
                            <th>Montant</th>
                            <th>Echeance</th>
                            <th>Statut</th>
                        </tr>
                    </thead>
                    <tbody id="recentInvoices">
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
            loadFinanceDashboard();
        });

        function buildFilterParams() {
            const from = document.getElementById('filterFrom').value;
            const to = document.getElementById('filterTo').value;
            const status = document.getElementById('filterStatus').value;
            const type = document.getElementById('filterType').value;
            const params = [];
            if (from) params.push('from=' + from);
            if (to) params.push('to=' + to);
            if (status) params.push('status=' + status);
            if (type) params.push('type=' + type);
            return params.join('&');
        }

        function applyFilters() {
            loadFinanceDashboard();
        }

        function resetFilters() {
            document.getElementById('filterFrom').value = '';
            document.getElementById('filterTo').value = '';
            document.getElementById('filterStatus').value = '';
            document.getElementById('filterType').value = '';
            loadFinanceDashboard();
        }

        function loadFinanceDashboard() {
            loadInvoiceMetrics();
            loadRecentInvoices();
            loadCharts();
        }

        function loadInvoiceMetrics() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/invoices/metrics' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const metrics = response.data || response;
                    document.getElementById('totalRevenue').textContent = formatCurrency(metrics.totalRevenue || 0);
                    document.getElementById('totalExpenses').textContent = formatCurrency(metrics.totalExpenses || 0);
                    document.getElementById('profitMargin').textContent = (metrics.profitMargin || 0) + '%';
                    document.getElementById('outstandingInvoices').textContent = formatCurrency(metrics.outstanding || 0);
                },
                function() { console.error('Failed to load metrics'); }
            );
        }

        function loadRecentInvoices() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/invoices?size=5&sort=dateCreation,desc' + (qs ? ('&' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const invoices = response.data || response;
                    displayRecentInvoices(invoices);
                },
                function() { console.error('Failed to load invoices'); }
            );
        }

        function displayRecentInvoices(invoices) {
            const tbody = document.getElementById('recentInvoices');
            tbody.innerHTML = '';

            if (!invoices || invoices.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5">Aucune facture</td></tr>';
                return;
            }

            invoices.forEach(inv => {
                const tr = document.createElement('tr');
                const statusClass = getStatusClass(inv.statut);
                const status = `<span class="badge badge-\${statusClass}">\${inv.statut}</span>`;

                tr.innerHTML = `
                    <td>\${inv.numero}</td>
                    <td>\${inv.clientLibelle || '-'}</td>
                    <td>\${formatCurrency(inv.montantTotal || 0)}</td>
                    <td>\${inv.dateLimite ? new Date(inv.dateLimite).toLocaleDateString() : '-'}</td>
                    <td>\${status}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function loadCharts() {
            const qs = buildFilterParams();
            const url = '/erp-system/api/charts/finance' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null,
                function(response) {
                    const data = response.data || response || {};
                    const revenue = data.revenue || { labels: [], data: [] };
                    const expenses = data.expenses || { labels: [], data: [] };
                    const cashFlow = data.cashFlow || { labels: [], data: [] };
                    const paymentStatus = data.paymentStatus || { labels: [], data: [] };

                    Dashboard.createChart('revenueChart', 'bar', {
                        labels: revenue.labels,
                        datasets: [
                            {
                                label: 'Revenus (Ar)',
                                data: revenue.data,
                                backgroundColor: '#28a745'
                            },
                            {
                                label: 'Depenses (Ar)',
                                data: expenses.data,
                                backgroundColor: '#dc3545'
                            }
                        ]
                    });

                    Dashboard.createChart('cashFlowChart', 'line', {
                        labels: cashFlow.labels,
                        datasets: [{
                            label: 'Flux (Ar)',
                            data: cashFlow.data,
                            borderColor: '#007bff',
                            fill: false
                        }]
                    });

                    Dashboard.createChart('paymentStatusChart', 'doughnut', {
                        labels: paymentStatus.labels,
                        datasets: [{
                            data: paymentStatus.data,
                            backgroundColor: ['#28a745', '#ffc107', '#dc3545', '#6c757d']
                        }]
                    });
                },
                function() { console.error('Erreur chargement des graphiques'); }
            );
        }

        function getStatusClass(status) {
            if (!status) return 'secondary';
            const s = status.toUpperCase();
            if (['PAYEE', 'PAID'].includes(s)) return 'success';
            if (['EN_ATTENTE'].includes(s)) return 'warning';
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
