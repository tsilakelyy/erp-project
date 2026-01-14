<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Logs - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/css/style-tables.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Audit Logs</h1>
                <button class="btn btn-secondary" onclick="exportLogs()">Export</button>
            </div>

            <div class="filters">
                <div class="filter-group">
                    <label>Table:</label>
                    <select id="filterTable" onchange="applyFilters()">
                        <option value="">All Tables</option>
                        <option value="articles">Articles</option>
                        <option value="fournisseurs">Suppliers</option>
                        <option value="clients">Customers</option>
                        <option value="commandes_achat">Purchase Orders</option>
                        <option value="commandes_vente">Sales Orders</option>
                    </select>
                </div>

                <div class="filter-group">
                    <label>Action:</label>
                    <select id="filterAction" onchange="applyFilters()">
                        <option value="">All Actions</option>
                        <option value="INSERT">INSERT</option>
                        <option value="UPDATE">UPDATE</option>
                        <option value="DELETE">DELETE</option>
                    </select>
                </div>

                <div class="filter-group">
                    <label>User:</label>
                    <input type="text" id="filterUser" onkeyup="applyFilters()" placeholder="Filter by user">
                </div>

                <div class="filter-group">
                    <label>Date From:</label>
                    <input type="date" id="filterDateFrom" onchange="applyFilters()">
                </div>

                <div class="filter-group">
                    <label>Date To:</label>
                    <input type="date" id="filterDateTo" onchange="applyFilters()">
                </div>
            </div>

            <table class="table" id="logsTable">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Table</th>
                        <th>Entity ID</th>
                        <th>Action</th>
                        <th>User</th>
                        <th>Old Value</th>
                        <th>New Value</th>
                    </tr>
                </thead>
                <tbody id="logsList">
                    <!-- Populated by JavaScript -->
                </tbody>
            </table>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadLogs();
        });

        function loadLogs() {
            ajaxCall('/erp/api/audit-logs', 'GET', null,
                function(response) {
                    const logs = response.data || response;
                    displayLogs(logs);
                },
                function(error) { showError('Failed to load logs'); }
            );
        }

        function displayLogs(logs) {
            const tbody = document.getElementById('logsList');
            tbody.innerHTML = '';

            if (!logs || logs.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7">No logs found</td></tr>';
                return;
            }

            logs.forEach(log => {
                const tr = document.createElement('tr');
                const timestamp = new Date(log.dateCreation).toLocaleString();
                const oldValue = log.oldValue ? JSON.stringify(JSON.parse(log.oldValue)).substring(0, 50) + '...' : '-';
                const newValue = log.newValue ? JSON.stringify(JSON.parse(log.newValue)).substring(0, 50) + '...' : '-';

                tr.innerHTML = `
                    <td>${timestamp}</td>
                    <td>${log.nomTable}</td>
                    <td>${log.idEntity}</td>
                    <td><span class="badge badge-${log.action === 'INSERT' ? 'success' : log.action === 'UPDATE' ? 'info' : 'danger'}">${log.action}</span></td>
                    <td>${log.userCreated}</td>
                    <td title="${log.oldValue}">${oldValue}</td>
                    <td title="${log.newValue}">${newValue}</td>
                `;
                tbody.appendChild(tr);
            });
        }

        function applyFilters() {
            const table = document.getElementById('filterTable').value;
            const action = document.getElementById('filterAction').value;
            const user = document.getElementById('filterUser').value;
            const dateFrom = document.getElementById('filterDateFrom').value;
            const dateTo = document.getElementById('filterDateTo').value;

            let query = '/erp/api/audit-logs';
            const params = [];
            if (table) params.push('table=' + table);
            if (action) params.push('action=' + action);
            if (user) params.push('user=' + user);
            if (dateFrom) params.push('from=' + dateFrom);
            if (dateTo) params.push('to=' + dateTo);
            
            if (params.length > 0) query += '?' + params.join('&');

            ajaxCall(query, 'GET', null,
                function(response) {
                    const logs = response.data || response;
                    displayLogs(logs);
                },
                function(error) { showError('Failed to filter logs'); }
            );
        }

        function exportLogs() {
            const logs = document.getElementById('logsList').innerHTML;
            const csv = convertTableToCSV(document.getElementById('logsTable'));
            downloadCSV(csv, 'audit-logs.csv');
        }

        function convertTableToCSV(table) {
            const rows = [];
            const headers = Array.from(table.querySelectorAll('th')).map(h => h.textContent);
            rows.push(headers.join(','));

            table.querySelectorAll('tbody tr').forEach(tr => {
                const cells = Array.from(tr.querySelectorAll('td')).map(td => '"' + td.textContent + '"');
                rows.push(cells.join(','));
            });

            return rows.join('\n');
        }

        function downloadCSV(csv, filename) {
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            a.click();
        }
    </script>
</body>
</html>
