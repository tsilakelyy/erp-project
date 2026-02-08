<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Direction - ERP</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <style>
        .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin: 20px 0; }
        .kpi-card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-left: 4px solid #007bff; }
        .kpi-name { font-size: 13px; color: #666; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }
        .kpi-value { font-size: 32px; font-weight: bold; color: #333; margin: 12px 0; }
        .kpi-meta { display: flex; justify-content: space-between; align-items: center; margin-top: 12px; padding-top: 12px; border-top: 1px solid #eee; }
        .kpi-trend { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; }
        .kpi-trend.increasing { background: #d4edda; color: #155724; }
        .kpi-trend.decreasing { background: #f8d7da; color: #721c24; }
        .kpi-trend.stable { background: #e2e3e5; color: #383d41; }
        .kpi-target { font-size: 11px; color: #999; }
        .section-header { font-size: 18px; font-weight: bold; margin-top: 35px; margin-bottom: 15px; color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; display: flex; align-items: center; }
        .section-header::before { content: ''; display: inline-block; width: 4px; height: 24px; background: #007bff; margin-right: 12px; }
        .no-data-message { text-align: center; color: #999; padding: 60px 20px; font-size: 16px; }
        .filters-bar { background: #f8f9fa; padding: 15px; border-radius: 4px; margin-bottom: 25px; display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap; }
        .filter-group { display: flex; flex-direction: column; gap: 5px; }
        .filter-group label { font-size: 12px; font-weight: 500; color: #333; }
        .filter-group input, .filter-group select { padding: 6px 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 13px; }
        .btn-group { display: flex; gap: 10px; }
        .btn { padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 13px; font-weight: 500; }
        .btn-primary { background: #007bff; color: white; }
        .btn-primary:hover { background: #0056b3; }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-secondary:hover { background: #5a6268; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Direction Générale / Comité de Direction</h1>
                <p style="color: #666; margin-top: 8px; font-size: 14px;">Tableau de bord stratégique - KPIs de pilotage global</p>
            </div>

            <!-- FILTERS -->
            <div class="filters-bar">
                <div class="filter-group">
                    <label>Période du</label>
                    <input type="date" id="filterFrom" name="filterFrom">
                </div>
                <div class="filter-group">
                    <label>au</label>
                    <input type="date" id="filterTo" name="filterTo">
                </div>
                <div class="btn-group" style="margin-left: auto;">
                    <button class="btn btn-primary" onclick="applyFilters()">Appliquer les filtres</button>
                    <button class="btn btn-secondary" onclick="resetFilters()">Réinitialiser</button>
                </div>
            </div>

            <!-- NODATA CHECK -->
            <c:if test="${empty kpis}">
                <div class="no-data-message">
                    <p><strong>Aucun KPI disponible pour le moment.</strong></p>
                    <p style="margin-top: 10px; font-size: 13px; color: #ccc;">Les données de KPIs seront affichées ici une fois calculées.</p>
                </div>
            </c:if>

            <!-- KPI CARDS -->
            <c:if test="${not empty kpis}">
                <div class="section-header">KPIs Financiers & Commerciaux</div>
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="entry" varStatus="loop">
                        <c:if test="${loop.index <= 3}">
                            <div class="kpi-card">
                                <div class="kpi-name">${entry.value.kpiName}</div>
                                <div class="kpi-value">
                                    <c:choose>
                                        <c:when test="${entry.value.unit eq '€'}">
                                            <c:out value="${entry.value.value}" />€
                                        </c:when>
                                        <c:when test="${entry.value.unit eq '%'}">
                                            <c:out value="${entry.value.value}" />%
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${entry.value.value}" />
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="kpi-meta">
                                    <span class="kpi-trend ${entry.value.trend}">${entry.value.trend}</span>
                                    <span class="kpi-target">Cible: ${entry.value.target}</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <div class="section-header">Gestion des Stocks</div>
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="entry" varStatus="loop">
                        <c:if test="${loop.index > 3 && loop.index <= 7}">
                            <div class="kpi-card">
                                <div class="kpi-name">${entry.value.kpiName}</div>
                                <div class="kpi-value">
                                    <c:choose>
                                        <c:when test="${entry.value.unit eq '€'}">
                                            <c:out value="${entry.value.value}" />€
                                        </c:when>
                                        <c:when test="${entry.value.unit eq '%'}">
                                            <c:out value="${entry.value.value}" />%
                                        </c:when>
                                        <c:when test="${entry.value.unit eq 'fois/an'}">
                                            <c:out value="${entry.value.value}" />x
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${entry.value.value}" />
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="kpi-meta">
                                    <span class="kpi-trend ${entry.value.trend}">${entry.value.trend}</span>
                                    <span class="kpi-target">Cible: ${entry.value.target}</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <div class="section-header">Qualité & Précision Inventory</div>
                <div class="kpi-grid">
                    <c:forEach items="${kpis}" var="entry" varStatus="loop">
                        <c:if test="${loop.index > 7}">
                            <div class="kpi-card">
                                <div class="kpi-name">${entry.value.kpiName}</div>
                                <div class="kpi-value">
                                    <c:choose>
                                        <c:when test="${entry.value.unit eq '€'}">
                                            <c:out value="${entry.value.value}" />€
                                        </c:when>
                                        <c:when test="${entry.value.unit eq '%'}">
                                            <c:out value="${entry.value.value}" />%
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${entry.value.value}" />
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="kpi-meta">
                                    <span class="kpi-trend ${entry.value.trend}">${entry.value.trend}</span>
                                    <span class="kpi-target">Cible: ${entry.value.target}</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </c:if>

            <!-- CHART SECTION -->
            <div style="margin-top: 40px;">
                <h2 style="margin-bottom: 20px;">Analyses & Graphiques</h2>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 30px;">
                    <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                        <h3 style="margin-bottom: 15px;">Évolution CA (12 derniers mois)</h3>
                        <canvas id="chartCA" style="max-height: 300px;"></canvas>
                    </div>
                    <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                        <h3 style="margin-bottom: 15px;">Marge Brute (%)</h3>
                        <canvas id="chartMargin" style="max-height: 300px;"></canvas>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        function applyFilters() {
            location.reload();
        }
        function resetFilters() {
            document.getElementById('filterFrom').value = '';
            document.getElementById('filterTo').value = '';
            location.reload();
        }
    </script>
</body>
</html>
