<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste de Prix - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Liste de Prix: ${pricingList.libelle}</h1>
                <div>
                    <a href="<c:url value='/admin/pricing-lists/${pricingList.id}/edit'/>" class="btn btn-info">Modifier</a>
                    <a href="<c:url value='/admin/pricing-lists'/>" class="btn btn-secondary">Retour</a>
                </div>
            </div>

            <c:if test="${param.success}">
                <div class="alert alert-success">Opération réussie</div>
            </c:if>
            <c:if test="${param.error}">
                <div class="alert alert-danger">${param.error}</div>
            </c:if>

            <div class="info-grid">
                <div class="info-item">
                    <label>Code:</label>
                    <strong>${pricingList.code}</strong>
                </div>
                <div class="info-item">
                    <label>Type:</label>
                    <strong>${pricingList.typeListe}</strong>
                </div>
                <div class="info-item">
                    <label>Devise:</label>
                    <strong>${pricingList.devise}</strong>
                </div>
                <div class="info-item">
                    <label>Défaut:</label>
                    <strong><c:if test="${pricingList.parDefaut}">Oui</c:if><c:if test="${!pricingList.parDefaut}">Non</c:if></strong>
                </div>
            </div>

            <h2 style="margin-top: 30px;">Lignes de Prix</h2>

            <div class="add-line-form" style="background: #f5f5f5; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                <h4>Ajouter une Ligne</h4>
                <form id="addLineForm" method="POST" action="<c:url value='/admin/pricing-lists/${pricingList.id}'/>" style="display:flex; gap: 10px; flex-wrap: wrap;">
                    <select name="articleId" class="form-control" style="flex: 1; min-width: 200px;" required>
                        <option value="">-- Sélectionner un article --</option>
                        <c:forEach items="${articles}" var="article">
                            <option value="${article.id}">${article.code} - ${article.libelle}</option>
                        </c:forEach>
                    </select>
                    <input type="number" name="prixUnitaire" step="0.01" placeholder="Prix unitaire" class="form-control" style="flex: 0 0 150px;" required>
                    <input type="number" name="remisePourcentage" step="0.01" min="0" max="100" placeholder="Remise %" class="form-control" style="flex: 0 0 120px;">
                    <button type="submit" class="btn btn-success">Ajouter</button>
                </form>
            </div>

            <div class="table-wrapper">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Code Article</th>
                            <th>Libellé</th>
                            <th>Prix Unitaire</th>
                            <th>Remise %</th>
                            <th>Prix Net</th>
                            <th>Actif</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${lines}" var="line">
                            <tr data-pricing-id="${line.id}">
                                <td>
                                    <a href="<c:url value='/articles/${line.article.id}'/>" style="text-decoration: none; font-weight: bold;">
                                        ${line.article.code}
                                    </a>
                                </td>
                                <td>
                                    <a href="<c:url value='/articles/${line.article.id}'/>" style="text-decoration: none;">
                                        ${line.article.libelle}
                                    </a>
                                </td>
                                <td>${line.prixUnitaire}</td>
                                <td>${line.remisePourcentage}%</td>
                                <td><strong>${line.prixNet}</strong></td>
                                <td>
                                    <c:if test="${line.actif}">
                                        <span class="badge badge-success">Actif</span>
                                    </c:if>
                                    <c:if test="${!line.actif}">
                                        <span class="badge badge-danger">Inactif</span>
                                    </c:if>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-primary" onclick="enableInlineEditPricing('${line.id}')">Modifier</button>
                                    <form method="POST" action="<c:url value='/admin/pricing-lists/${pricingList.id}'/>" style="display:inline;" onsubmit="return confirm('Confirmer la suppression ?');">
                                        <input type="hidden" name="lineId" value="${line.id}"/>
                                        <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <c:if test="${empty lines}">
                    <p class="text-center text-muted">Aucune ligne</p>
                </c:if>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script>
    function enableInlineEditPricing(pricingId) {
        const row = document.querySelector(`[data-pricing-id="${pricingId}"]`);
        const cells = row.querySelectorAll('td');

        cells[1].innerHTML = `<input type='text' value='${cells[1].innerText}' class='form-control' id='libelle-${pricingId}' />`;
        cells[2].innerHTML = `<input type='text' value='${cells[2].innerText}' class='form-control' id='type-${pricingId}' />`;

        const actionsCell = cells[4];
        actionsCell.innerHTML = `
            <button class='btn btn-sm btn-success' onclick='savePricing(${pricingId})'>Enregistrer</button>
            <button class='btn btn-sm btn-secondary' onclick='cancelEditPricing(${pricingId})'>Annuler</button>
        `;
    }
    </script>
</body>
</html>
