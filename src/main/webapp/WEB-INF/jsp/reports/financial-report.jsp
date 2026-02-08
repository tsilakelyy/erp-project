<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport financier - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Rapport financier</h1>
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
            </div>

            <div class="report-section">
                <h3>Synthese financiere</h3>
                <div class="metrics-grid">
                    <div class="metric-box">
                        <div class="metric-label">Chiffre d'affaires</div>
                        <div class="metric-value" id="totalRevenue">0 Ar</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Depenses</div>
                        <div class="metric-value" id="totalExpenses">0 Ar</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Benefice net</div>
                        <div class="metric-value" id="netProfit">0 Ar</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Marge</div>
                        <div class="metric-value" id="profitMargin">0%</div>
                        <div class="metric-unit">du chiffre d'affaires</div>
                    </div>
                </div>
            </div>

            <div class="report-section">
                <h3>Progression globale</h3>
                <div class="report-bars" id="financeBars"></div>
            </div>

            <div class="report-section">
                <h3>Statut des factures</h3>
                <div class="report-bars" id="invoiceStatusBars"></div>
            </div>

            <div class="data-section">
                <h3>Synthese mensuelle</h3>
                <table class="table table-striped" id="financialTable">
                    <thead>
                        <tr>
                            <th>Mois</th>
                            <th>Revenus</th>
                            <th>Depenses</th>
                            <th>Benefice</th>
                            <th>Marge %</th>
                            <th>Flux de tresorerie</th>
                        </tr>
                    </thead>
                    <tbody id="financialList">
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

            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            let url = base + '/api/reports/financial';
            const params = [];
            if (dateFrom) params.push('from=' + dateFrom);
            if (dateTo) params.push('to=' + dateTo);

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

            document.getElementById('totalRevenue').textContent = formatCurrency(data.totalRevenue || 0);
            document.getElementById('totalExpenses').textContent = formatCurrency(data.totalExpenses || 0);
            document.getElementById('netProfit').textContent = formatCurrency(data.netProfit || 0);
            document.getElementById('profitMargin').textContent = (data.profitMargin || 0).toFixed(1) + '%';

            renderFinanceBars(data);
            renderStatusBars(data.statusSummary || {}, data.totalRevenue || 0, data.totalExpenses || 0);
            displayFinancialSummary(data.monthlySummary || []);
        }

        function renderFinanceBars(data) {
            const revenue = Number(data.totalRevenue || 0);
            const expenses = Number(data.totalExpenses || 0);
            const profit = Number(data.netProfit || 0);
            const max = Math.max(revenue, expenses, Math.abs(profit), 1);

            const items = [
                { label: 'Revenus', value: percent(revenue, max), note: formatCurrency(revenue), tone: 'success' },
                { label: 'Depenses', value: percent(expenses, max), note: formatCurrency(expenses), tone: 'danger' },
                { label: 'Benefice', value: percent(Math.max(profit, 0), max), note: formatCurrency(profit), tone: profit >= 0 ? 'info' : 'warning' }
            ];
            ReportBars.render(document.getElementById('financeBars'), items);
        }

        function renderStatusBars(summary, totalRevenue, totalExpenses) {
            const total = Object.values(summary || {}).reduce((acc, v) => acc + (v || 0), 0);
            const items = Object.keys(summary || {}).map(key => {
                const count = summary[key] || 0;
                return {
                    label: key,
                    value: percent(count, total),
                    note: count + ' factures',
                    tone: toneForStatus(key)
                };
            });
            ReportBars.render(document.getElementById('invoiceStatusBars'), items);
        }

        function displayFinancialSummary(summary) {
            const tbody = document.getElementById('financialList');
            tbody.innerHTML = '';

            if (!summary || summary.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">Aucune donnee</td></tr>';
                return;
            }

            summary.forEach(month => {
                const tr = document.createElement('tr');
                const margin = month.revenue > 0 ? ((month.profit / month.revenue) * 100).toFixed(1) : 0;

                tr.innerHTML =
                    '<td>' + month.month + '</td>' +
                    '<td>' + formatCurrency(month.revenue) + '</td>' +
                    '<td>' + formatCurrency(month.expenses) + '</td>' +
                    '<td>' + formatCurrency(month.profit) + '</td>' +
                    '<td>' + margin + '%</td>' +
                    '<td>' + formatCurrency(month.cashFlow) + '</td>';
                tbody.appendChild(tr);
            });
        }

        function percent(part, total) {
            if (!total) return 0;
            return Math.round((part * 100) / total);
        }

        function toneForStatus(status) {
            const value = (status || '').toUpperCase();
            if (value.includes('PAYEE') || value.includes('PAID')) return 'success';
            if (value.includes('ATTENTE') || value.includes('EN_COURS')) return 'warning';
            if (value.includes('ANNULEE') || value.includes('REJET')) return 'danger';
            return 'info';
        }

        function refreshReport() {
            generateReport();
        }

        function exportExcel() {
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            window.location.href = base + '/api/reports/financial.xlsx';
        }
    </script>
</body>
</html>
