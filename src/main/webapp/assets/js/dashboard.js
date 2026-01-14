// Dashboard utilities for KPI and chart management
class Dashboard {
    static loadKPIs(role, containerId) {
        const container = document.getElementById(containerId);
        if (!container) return;

        fetch(`/erp/api/kpis/${role}`, {
            headers: {'Authorization': 'Bearer ' + getToken()}
        })
        .then(r => r.json())
        .then(response => {
            const kpis = response.data || response;
            this.renderKPIs(kpis, container);
        })
        .catch(err => console.error('Failed to load KPIs', err));
    }

    static renderKPIs(kpis, container) {
        container.innerHTML = '';
        if (!kpis || kpis.length === 0) {
            container.innerHTML = '<p>No KPI data</p>';
            return;
        }

        kpis.forEach(kpi => {
            const card = document.createElement('div');
            card.className = `kpi-card kpi-${kpi.id}`;
            const trendClass = kpi.trend === 'UP' ? 'trend-up' : kpi.trend === 'DOWN' ? 'trend-down' : 'trend-stable';
            
            card.innerHTML = `
                <div class="kpi-header">
                    <span class="kpi-label">${kpi.libelle}</span>
                    <span class="kpi-trend ${trendClass}">${kpi.trend}</span>
                </div>
                <div class="kpi-value">${kpi.value}</div>
                <div class="kpi-details">
                    <span class="kpi-unit">${kpi.unit}</span>
                    <span class="kpi-variance">Target: ${kpi.target} (${kpi.variance > 0 ? '+' : ''}${kpi.variance}%)</span>
                </div>
            `;
            container.appendChild(card);
        });
    }

    static createChart(canvasId, type, data) {
        const canvas = document.getElementById(canvasId);
        if (!canvas || typeof Chart === 'undefined') return;

        return new Chart(canvas, {
            type: type,
            data: data,
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'top'
                    }
                }
            }
        });
    }

    static loadTableData(apiUrl, tableId) {
        const table = document.getElementById(tableId);
        if (!table) return;

        fetch(apiUrl, {
            headers: {'Authorization': 'Bearer ' + getToken()}
        })
        .then(r => r.json())
        .then(response => {
            const data = response.data || response;
            this.renderTableData(data, table);
        })
        .catch(err => console.error('Failed to load data', err));
    }

    static renderTableData(data, table) {
        const tbody = table.querySelector('tbody');
        if (!tbody) return;

        tbody.innerHTML = '';
        if (!data || data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="100%">No data</td></tr>';
            return;
        }

        data.forEach(row => {
            const tr = document.createElement('tr');
            Object.values(row).forEach(value => {
                const td = document.createElement('td');
                td.textContent = value;
                tr.appendChild(td);
            });
            tbody.appendChild(tr);
        });
    }
}
