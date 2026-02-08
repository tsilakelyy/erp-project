<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Suivi validations - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Suivi des validations</h1>
                <a href="<c:url value='/reports/purchases'/>" class="btn btn-secondary">Retour rapports</a>
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
                    <label>Statut global</label>
                    <select id="filterStatus">
                        <option value="">Tous</option>
                        <option value="EN_ATTENTE">En attente</option>
                        <option value="VALIDEE">Validee</option>
                        <option value="APPROUVEE">Approuvee</option>
                        <option value="EN_COURS">En cours</option>
                        <option value="RECUE">Recue</option>
                        <option value="FACTUREE">Facturee</option>
                        <option value="PAYEE">Payee</option>
                        <option value="REJETEE">Rejetee</option>
                        <option value="ANNULEE">Annulee</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Importance</label>
                    <select id="filterImportance">
                        <option value="">Toutes</option>
                        <option value="FAIBLE">Faible</option>
                        <option value="MOYENNE">Moyenne</option>
                        <option value="ELEVEE">Elevee</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Mode validation</label>
                    <select id="filterMode">
                        <option value="">Tous</option>
                        <option value="AUTO">Auto</option>
                        <option value="FINANCE">Finance</option>
                        <option value="DIRECTION">Direction</option>
                        <option value="FINANCE_DIRECTION">Finance + Direction</option>
                    </select>
                </div>
                <div class="filter-actions">
                    <button class="btn btn-secondary" type="button" onclick="applyValidationFilters()">Appliquer</button>
                    <button class="btn btn-secondary" type="button" onclick="resetValidationFilters()">Reinitialiser</button>
                </div>
            </div>

            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Processus suivis</div>
                    <div class="kpi-value" id="kpiTotal">0</div>
                    <div class="kpi-unit">Total</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-label">Completes</div>
                    <div class="kpi-value" id="kpiComplete">0</div>
                    <div class="kpi-unit">100%</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-label">En attente</div>
                    <div class="kpi-value" id="kpiPending">0</div>
                    <div class="kpi-unit">En cours</div>
                </div>
            </div>

            <table class="table table-striped" id="validationTable">
                <thead>
                    <tr>
                        <th>Demande</th>
                        <th>Proforma</th>
                        <th>Commande</th>
                        <th>Reception</th>
                        <th>Facture</th>
                        <th>Statut global</th>
                        <th>Avancement</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="validationBody">
                    <tr><td colspan="8">Chargement...</td></tr>
                </tbody>
            </table>

            <h2 style="margin-top: 32px;">Suivi du cycle de vente</h2>
            <div class="kpi-cards">
                <div class="kpi-card">
                    <div class="kpi-label">Processus ventes</div>
                    <div class="kpi-value" id="salesTotal">0</div>
                    <div class="kpi-unit">Total</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-label">Completes</div>
                    <div class="kpi-value" id="salesComplete">0</div>
                    <div class="kpi-unit">100%</div>
                </div>
                <div class="kpi-card">
                    <div class="kpi-label">En attente</div>
                    <div class="kpi-value" id="salesPending">0</div>
                    <div class="kpi-unit">En cours</div>
                </div>
            </div>

            <table class="table table-striped" id="salesCycleTable">
                <thead>
                    <tr>
                        <th>Devis</th>
                        <th>Commande</th>
                        <th>Livraison</th>
                        <th>Facture</th>
                        <th>Paiement</th>
                        <th>Statut global</th>
                        <th>Avancement</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="salesCycleBody">
                    <tr><td colspan="8">Chargement...</td></tr>
                </tbody>
            </table>
        </div>
    </div>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadValidationReport();
            loadSalesCycleReport();
        });

        function buildValidationParams() {
            const params = [];
            const from = document.getElementById('filterFrom').value;
            const to = document.getElementById('filterTo').value;
            const status = document.getElementById('filterStatus').value;
            const importance = document.getElementById('filterImportance').value;
            const mode = document.getElementById('filterMode').value;
            if (from) params.push('from=' + from);
            if (to) params.push('to=' + to);
            if (status) params.push('status=' + status);
            if (importance) params.push('importance=' + importance);
            if (mode) params.push('mode=' + mode);
            return params.join('&');
        }

        function applyValidationFilters() {
            loadValidationReport();
        }

        function resetValidationFilters() {
            document.getElementById('filterFrom').value = '';
            document.getElementById('filterTo').value = '';
            document.getElementById('filterStatus').value = '';
            document.getElementById('filterImportance').value = '';
            document.getElementById('filterMode').value = '';
            loadValidationReport();
        }

        function loadValidationReport() {
            const qs = buildValidationParams();
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            const url = base + '/api/reports/validations' + (qs ? ('?' + qs) : '');
            ajaxCall(url, 'GET', null, function(response) {
                const data = response.data || response || {};
                renderValidationReport(data.items || []);
                document.getElementById('kpiTotal').textContent = data.total || 0;
                document.getElementById('kpiComplete').textContent = data.complete || 0;
                document.getElementById('kpiPending').textContent = data.pending || 0;
            }, function(err) {
                console.error('Erreur report validations', err);
            });
        }

        function renderValidationReport(items) {
            const tbody = document.getElementById('validationBody');
            tbody.innerHTML = '';
            if (!items || items.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8">Aucun suivi disponible</td></tr>';
                return;
            }

            items.forEach(item => {
                const progress = item.progress || 0;
                const actionLink = resolveActionLink(item);
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>\${safe(item.requestNumero)}</td>
                    <td>\${safe(item.proformaNumero)}</td>
                    <td>\${safe(item.orderNumero)}</td>
                    <td>\${safe(item.receiptNumero)}</td>
                    <td>\${safe(item.invoiceNumero)}</td>
                    <td>\${safe(item.overallStatus)}</td>
                    <td>
                        <div class="smart-progress"><div class="smart-progress-bar" style="width:\${progress}%"></div></div>
                        <div class="smart-progress-label">\${progress}%</div>
                    </td>
                    <td>\${actionLink}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function resolveActionLink(item) {
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            if (item.orderId) return `<a class="btn btn-sm btn-info" href="\${base}/purchases/orders/\${item.orderId}">Voir</a>`;
            if (item.proformaId) return `<a class="btn btn-sm btn-info" href="\${base}/purchases/proformas/\${item.proformaId}">Voir</a>`;
            if (item.requestId) return `<a class="btn btn-sm btn-info" href="\${base}/purchases/requests/\${item.requestId}">Voir</a>`;
            return '-';
        }

        function loadSalesCycleReport() {
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            const url = base + '/api/reports/sales-cycle';
            ajaxCall(url, 'GET', null, function(response) {
                const data = response.data || response || {};
                renderSalesCycleReport(data.items || []);
                document.getElementById('salesTotal').textContent = data.total || 0;
                document.getElementById('salesComplete').textContent = data.complete || 0;
                document.getElementById('salesPending').textContent = data.pending || 0;
            }, function(err) {
                console.error('Erreur report cycle ventes', err);
            });
        }

        function renderSalesCycleReport(items) {
            const tbody = document.getElementById('salesCycleBody');
            tbody.innerHTML = '';
            if (!items || items.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8">Aucun suivi disponible</td></tr>';
                return;
            }

            items.forEach(item => {
                const progress = item.progress || 0;
                const actionLink = resolveSalesActionLink(item);
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>\${safe(item.proformaNumero)}</td>
                    <td>\${safe(item.orderNumero)}</td>
                    <td>\${safe(item.deliveryNumero)}</td>
                    <td>\${safe(item.invoiceNumero)}</td>
                    <td>\${safe(item.paymentNumero)}</td>
                    <td>\${safe(item.overallStatus)}</td>
                    <td>
                        <div class="smart-progress"><div class="smart-progress-bar" style="width:\${progress}%"></div></div>
                        <div class="smart-progress-label">\${progress}%</div>
                    </td>
                    <td>\${actionLink}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function resolveSalesActionLink(item) {
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            if (item.proformaId) return `<a class="btn btn-sm btn-info" href="\${base}/sales/proformas/\${item.proformaId}">Voir</a>`;
            if (item.invoiceId) return `<a class="btn btn-sm btn-info" href="\${base}/sales/invoices/\${item.invoiceId}">Voir</a>`;
            if (item.deliveryId) return `<a class="btn btn-sm btn-info" href="\${base}/sales/deliveries/\${item.deliveryId}">Voir</a>`;
            if (item.orderId) return `<a class="btn btn-sm btn-info" href="\${base}/sales/orders/\${item.orderId}">Voir</a>`;
            if (item.requestId) return `<a class="btn btn-sm btn-info" href="\${base}/sales/client-requests">Voir</a>`;
            return '-';
        }

        function safe(value) {
            return value ? value : '-';
        }
    </script>
</body>
</html>
