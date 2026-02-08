<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Niveaux de stock - ERP</title>
<jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Niveaux de stock</h1>
            </div>

            <div id="adjustmentsContainer" class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Article</th>
                            <th>Entrepot</th>
                            <th>Quantite actuelle</th>
                            <th>Quantite reservee</th>
                            <th>Quantite disponible</th>
                            <th>Statut</th>
                        </tr>
                    </thead>
                    <tbody id="adjustmentsTableBody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadStockLevels();
        });

        function loadStockLevels() {
            ajaxCall('/erp-system/api/stock-levels', 'GET', null,
                function(response) {
                    const stocks = response.data || response;
                    renderStockTable(stocks);
                },
                function() { showError('Chargement impossible'); }
            );
        }

        function renderStockTable(stocks) {
            const tbody = document.getElementById('adjustmentsTableBody');
            tbody.innerHTML = '';

            if (!stocks || stocks.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6">Aucun stock</td></tr>';
                return;
            }

            stocks.forEach(stock => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>\${stock.articleCode}</td>
                    <td>\${stock.entrepotCode}</td>
                    <td>\${stock.quantiteActuelle}</td>
                    <td>\${stock.quantiteReservee}</td>
                    <td><span class="badge badge-success">\${stock.quantiteDisponible}</span></td>
                    <td>OK</td>
                `;
                tbody.appendChild(row);
            });
        }
    </script>
</body>
</html>
