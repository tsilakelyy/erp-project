<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapports - Vue globale</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Rapports - Vue globale</h1>
                <div>
                    <a href="<c:url value='/reports/purchases'/>" class="btn btn-secondary">Achats</a>
                    <a href="<c:url value='/reports/sales'/>" class="btn btn-secondary">Ventes</a>
                    <a href="<c:url value='/reports/financial'/>" class="btn btn-secondary">Finance</a>
                    <a href="<c:url value='/reports/inventory'/>" class="btn btn-secondary">Stocks</a>
                    <a href="<c:url value='/reports/validations'/>" class="btn btn-secondary">Validations</a>
                </div>
            </div>

            <div class="report-section">
                <h3>Barometre des performances</h3>
                <div class="report-bars" id="reportsOverviewBars"></div>
            </div>

            <div class="report-section">
                <h3>Avancements detaillees</h3>
                <div class="report-bars" id="reportsSpecificBars"></div>
            </div>

            <div class="report-section">
                <h3>Volumes suivis</h3>
                <div class="metrics-grid">
                    <div class="metric-box">
                        <div class="metric-label">Commandes achats</div>
                        <div class="metric-value" id="countPurchases">0</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Commandes ventes</div>
                        <div class="metric-value" id="countSales">0</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Factures</div>
                        <div class="metric-value" id="countInvoices">0</div>
                    </div>
                    <div class="metric-box">
                        <div class="metric-label">Articles stock</div>
                        <div class="metric-value" id="countStock">0</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script src="<c:url value='/assets/js/report-bars.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadOverview();
        });

        function loadOverview() {
            const base = (typeof APP_CONTEXT !== 'undefined' ? APP_CONTEXT : '');
            const url = base + '/api/reports/overview';
            ajaxCall(url, 'GET', null,
                function(response) {
                    const data = response.data || response || {};
                    ReportBars.render(document.getElementById('reportsOverviewBars'), data.bars || []);
                    ReportBars.render(document.getElementById('reportsSpecificBars'), data.specificBars || []);
                    const counts = data.counts || {};
                    document.getElementById('countPurchases').textContent = counts.purchases || 0;
                    document.getElementById('countSales').textContent = counts.sales || 0;
                    document.getElementById('countInvoices').textContent = counts.invoices || 0;
                    document.getElementById('countStock').textContent = counts.stockItems || 0;
                },
                function() { showError('Impossible de charger les rapports globaux'); }
            );
        }
    </script>
</body>
</html>
