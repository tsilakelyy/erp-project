<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Achats - ERP</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <style>
        .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin: 20px 0; }
        .kpi-card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-left: 4px solid #28a745; }
        .kpi-name { font-size: 13px; color: #666; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }
        .kpi-value { font-size: 32px; font-weight: bold; color: #333; margin: 12px 0; }
        .kpi-meta { display: flex; justify-content: space-between; align-items: center; margin-top: 12px; padding-top: 12px; border-top: 1px solid #eee; }
        .kpi-trend { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }
        .kpi-trend.increasing { background: #d4edda; color: #155724; }
        .kpi-trend.decreasing { background: #f8d7da; color: #721c24; }
        .kpi-trend.stable { background: #e2e3e5; color: #383d41; }
        .kpi-target { font-size: 11px; color: #999; }
        .section-header { font-size: 18px; font-weight: bold; margin-top: 35px; margin-bottom: 15px; color: #333; border-bottom: 2px solid #28a745; padding-bottom: 10px; display: flex; align-items: center; }
        .section-header::before { content: ''; display: inline-block; width: 4px; height: 24px; background: #28a745; margin-right: 12px; }
        .filters-bar { background: #f8f9fa; padding: 15px; border-radius: 4px; margin-bottom: 25px; display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap; }
        .filter-group { display: flex; flex-direction: column; gap: 5px; }
        .filter-group label { font-size: 12px; font-weight: 500; color: #333; }
        .filter-group input, .filter-group select { padding: 6px 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 13px; }
        .btn { padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 13px; font-weight: 500; }
        .btn-primary { background: #28a745; color: white; }
        .btn-primary:hover { background: #218838; }
        .btn-secondary { background: #6c757d; color: white; }
        .no-data { text-align: center; color: #999; padding: 60px 20px; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Responsable Achats / Supply Chain</h1>
                <p style="color: #666; margin-top: 8px; font-size: 14px;">KPIs d'approvisionnement et gestion fournisseurs</p>
            </div>

            <div class="filters-bar">
                <div class="filter-group">
                    <label>Période du</label>
                    <input type="date" id="filterFrom">
                </div>
                <div class="filter-group">
                    <label>au</label>
                    <input type="date" id="filterTo">
                </div>
                <div style="margin-left: auto; display: flex; gap: 10px;">
                    <button class="btn btn-primary" onclick="applyFilters()">Appliquer</button>
                    <button class="btn btn-secondary" onclick="resetFilters()">Réinitialiser</button>
                </div>
            </div>

            <c:if test="${empty kpis}">
                <div class="no-data">
                    <p><strong>Aucun KPI disponible</strong></p>
                </div>
            </c:if>

            <c:if test="${not empty kpis}">
                <div class="section-header">Performance Cycle Achat</div>
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="entry" varStatus="loop">
                        <c:if test="${loop.index <= 3}">
                            <div class="kpi-card">
                                <div class="kpi-name">${entry.value.kpiName}</div>
                                <div class="kpi-value"><c:out value="${entry.value.value}" /> ${entry.value.unit}</div>
                                <div class="kpi-meta">
                                    <span class="kpi-trend ${entry.value.trend}">${entry.value.trend}</span>
                                    <span class="kpi-target">Cible: ${entry.value.target}</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <div class="section-header">Qualité Réception & Conformité</div>
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="entry" varStatus="loop">
                        <c:if test="${loop.index > 3 && loop.index <= 6}">
                            <div class="kpi-card">
                                <div class="kpi-name">${entry.value.kpiName}</div>
                                <div class="kpi-value"><c:out value="${entry.value.value}" /> ${entry.value.unit}</div>
                                <div class="kpi-meta">
                                    <span class="kpi-trend ${entry.value.trend}">${entry.value.trend}</span>
                                    <span class="kpi-target">Cible: ${entry.value.target}</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <div class="section-header">Gestion Fournisseurs & Prix</div>
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="entry" varStatus="loop">
                        <c:if test="${loop.index > 6}">
                            <div class="kpi-card">
                                <div class="kpi-name">${entry.value.kpiName}</div>
                                <div class="kpi-value"><c:out value="${entry.value.value}" /> ${entry.value.unit}</div>
                                <div class="kpi-meta">
                                    <span class="kpi-trend ${entry.value.trend}">${entry.value.trend}</span>
                                    <span class="kpi-target">Cible: ${entry.value.target}</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>
    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        function applyFilters() { location.reload(); }
        function resetFilters() { document.getElementById('filterFrom').value = ''; document.getElementById('filterTo').value = ''; location.reload(); }
    </script>
</body>
</html>
