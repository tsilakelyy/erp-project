<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Fournisseurs - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - Fournisseurs</span>
    </nav>

    <div class="container mt-4">
        <c:if test="${param.success == '1'}">
            <div class="alert alert-success">Insertion reussie.</div>
        </c:if>
        <div class="mb-3">
            <a href="<c:url value='/suppliers/new'/>" class="btn btn-primary">+ Nouveau fournisseur</a>
        </div>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Entreprise</th>
                    <th>Email</th>
                    <th>Telephone</th>
                    <th>Statut</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${suppliers}" var="supplier">
                    <tr data-supplier-id="${supplier.id}">
                        <td>${supplier.code}</td>
                        <td>${supplier.nomEntreprise}</td>
                        <td>${supplier.email}</td>
                        <td>${supplier.telephone}</td>
                        <td>
                            <c:if test="${supplier.active}">
                                <span class="badge bg-success">Actif</span>
                            </c:if>
                            <c:if test="${!supplier.active}">
                                <span class="badge bg-danger">Inactif</span>
                            </c:if>
                        </td>
                        <td>
                            <a href="<c:url value='/suppliers/${supplier.id}'/>" class="btn btn-sm btn-info">Voir</a>
                            <a href="<c:url value='/suppliers/${supplier.id}/edit'/>" class="btn btn-sm btn-warning">Modifier</a>
                            <form method="POST" action="<c:url value='/suppliers/${supplier.id}/deactivate'/>" style="display:inline;">
                                <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                            </form>
                            <button class="btn btn-sm btn-secondary" onclick="enableInlineEditSupplier('${supplier.id}')">Éditer en ligne</button>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    function enableInlineEditSupplier(supplierId) {
        const row = document.querySelector(`[data-supplier-id="${supplierId}"]`);
        const cells = row.querySelectorAll('td');

        cells[1].innerHTML = `<input type='text' value='${cells[1].innerText}' class='form-control' id='name-${supplierId}' />`;
        cells[2].innerHTML = `<input type='text' value='${cells[2].innerText}' class='form-control' id='email-${supplierId}' />`;
        cells[3].innerHTML = `<input type='text' value='${cells[3].innerText}' class='form-control' id='phone-${supplierId}' />`;

        const actionsCell = cells[5];
        actionsCell.innerHTML = `
            <button class='btn btn-sm btn-success' onclick='saveSupplier(${supplierId})'>Enregistrer</button>
            <button class='btn btn-sm btn-secondary' onclick='cancelEditSupplier(${supplierId})'>Annuler</button>
        `;
    }

    function saveSupplier(supplierId) {
        const nomEntreprise = document.getElementById(`name-${supplierId}`).value;
        const email = document.getElementById(`email-${supplierId}`).value;
        const telephone = document.getElementById(`phone-${supplierId}`).value;

        fetch(`/suppliers/${supplierId}/update`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                nomEntreprise: nomEntreprise,
                email: email,
                telephone: telephone
            })
        })
        .then(response => {
            if (response.ok || response.status === 302) {
                location.reload();
            } else {
                alert('Erreur lors de la mise à jour du fournisseur.');
            }
        })
        .catch(error => console.error('Error:', error));
    }

    function cancelEditSupplier(supplierId) {
        location.reload();
    }
    </script>
    </div>
</body>
</html>
