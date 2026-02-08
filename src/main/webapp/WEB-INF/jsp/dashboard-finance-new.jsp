<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Finance - ERP</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <style>
        .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin: 20px 0; }
        .kpi-card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-left: 4px solid #dc3545; }
        .kpi-name { font-size: 13px; color: #666; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }
        .kpi-value { font-size: 32px; font-weight: bold; color: #333; margin: 12px 0; }
        .kpi-meta { display: flex; justify-content: space-between; align-items: center; margin-top: 12px; padding-top: 12px; border-top: 1px solid #eee; }
        .kpi-trend { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }
        .kpi-trend.increasing { background: #d4edda; color: #155724; }
        .kpi-trend.decreasing { background: #f8d7da; color: #721c24; }
        .kpi-trend.stable { background: #e2e3e5; color: #383d41; }
        .section-header { font-size: 18px; font-weight: bold; margin-top: 35px; margin-bottom: 15px; color: #333; border-bottom: 2px solid #dc3545; padding-bottom: 10px; display: flex; align-items: center; }
        .section-header::before { content: ''; display: inline-block; width: 4px; height: 24px; background: #dc3545; margin-right: 12px; }
        .filters-bar { background: #f8f9fa; padding: 15px; border-radius: 4px; margin-bottom: 25px; display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap; }
        .btn { padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 13px; font-weight: 500; }
        .btn-primary { background: #dc3545; color: white; }
        .btn-primary:hover { background: #c82333; }
        .btn-secondary { background: #6c757d; color: white; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Finance / Directeur Administratif et Financier (DAF)</h1>
                <p style="color: #666; margin-top: 8px; font-size: 14px;">KPIs financiers et de rapprochement comptable</p>
            </div>

            <div class="filters-bar">
                <div style="display: flex; flex-direction: column; gap: 5px;">
                    <label>Période du</label>
                    <input type="date" id="filterFrom">
                </div>
                <div style="display: flex; flex-direction: column; gap: 5px;">
                    <label>au</label>
                    <input type="date" id="filterTo">
                </div>
                <div style="margin-left: auto; display: flex; gap: 10px;">
                    <button class="btn btn-primary" onclick="applyFilters()">Appliquer</button>
                    <button class="btn btn-secondary" onclick="resetFilters()">Réinitialiser</button>
                </div>
            </div>

            <c:if test="${empty kpis}">
                <div style="text-align: center; color: #999; padding: 60px 20px;">
                    <p><strong>Aucun KPI disponible</strong></p>
                </div>
            </c:if>

            <c:if test="${not empty kpis}">
                <div class="section-header">Rapprochement & Factures</div>
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="entry" varStatus="loop">
                        <c:if test="${loop.index <= 2}">
                            <div class="kpi-card">
                                <div class="kpi-name">${entry.value.kpiName}</div>
                                <div class="kpi-value"><c:out value="${entry.value.value}" /> ${entry.value.unit}</div>
                                <div class="kpi-meta">
                                    <span class="kpi-trend ${entry.value.trend}">${entry.value.trend}</span>
                                    <span style="font-size: 11px; color: #999;">Cible: ${entry.value.target}</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <div class="section-header">Valuation Stock & Écarts</div>
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="entry" varStatus="loop">
                        <c:if test="${loop.index > 2 && loop.index <= 5}">
                            <div class="kpi-card">
                                <div class="kpi-name">${entry.value.kpiName}</div>
                                <div class="kpi-value"><c:out value="${entry.value.value}" /> ${entry.value.unit}</div>
                                <div class="kpi-meta">
                                    <span class="kpi-trend ${entry.value.trend}">${entry.value.trend}</span>
                                    <span style="font-size: 11px; color: #999;">Cible: ${entry.value.target}</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <div class="section-header">Trésorerie & Créances/Dettes</div>
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="entry" varStatus="loop">
                        <c:if test="${loop.index > 5}">
                            <div class="kpi-card">
                                <div class="kpi-name">${entry.value.kpiName}</div>
                                <div class="kpi-value"><c:out value="${entry.value.value}" /> ${entry.value.unit}</div>
                                <div class="kpi-meta">
                                    <span class="kpi-trend ${entry.value.trend}">${entry.value.trend}</span>
                                    <span style="font-size: 11px; color: #999;">Cible: ${entry.value.target}</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </c:if>

            <div style="margin-top: 40px;">
                <h2 style="margin-bottom: 20px;">Analyses Financières</h2>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 30px;">
                    <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                        <h3 style="margin-bottom: 15px;">Trésorerie (12 derniers mois)</h3>
                        <canvas id="chartTresorerie" style="max-height: 300px;"></canvas>
                    </div>
                    <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                        <h3 style="margin-bottom: 15px;">Créances vs Dettes</h3>
                        <canvas id="chartCreancesDettes" style="max-height: 300px;"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>
    <script>
        function applyFilters() { location.reload(); }
        function resetFilters() { document.getElementById('filterFrom').value = ''; document.getElementById('filterTo').value = ''; location.reload(); }
    </script>
</body>
</html>
