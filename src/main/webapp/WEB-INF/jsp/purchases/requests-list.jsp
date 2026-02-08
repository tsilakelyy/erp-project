<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Demandes d'achat - ERP</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Demandes d'achat</h1>
                <a href="<c:url value='/purchases/requests/new'/>" class="btn btn-primary">+ Nouvelle demande</a>
            </div>
            <c:if test="${param.success == '1'}">
                <div class="alert alert-success">Insertion reussie.</div>
            </c:if>

            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Numero</th>
                        <th>Statut</th>
                        <th>Creation</th>
                        <th>Montant estime</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${requests}" var="request">
                        <tr data-request-id="${request.id}">
                            <td>${request.numero}</td>
                            <td>${request.statut}</td>
                            <td>${request.dateCreation}</td>
                        <td>Ar ${request.montantEstime}</td>
                        <td>
                            <a href="<c:url value='/purchases/requests/${request.id}'/>" class="btn btn-sm btn-info">Voir</a>
                            <a href="<c:url value='/purchases/requests/${request.id}'/>" class="btn btn-sm btn-warning">Modifier</a>
                            <form method="POST" action="<c:url value='/purchases/requests/${request.id}/reject'/>" style="display:inline;">
                                <button type="submit" class="btn btn-sm btn-danger">Supprimer</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <script>
    function enableInlineEditRequest(requestId) {
        const row = document.querySelector(`[data-request-id="${requestId}"]`);
        const cells = row.querySelectorAll('td');

        cells[1].innerHTML = `<input type='text' value='${cells[1].innerText}' class='form-control' id='montant-${requestId}' />`;

        const actionsCell = cells[4];
        actionsCell.innerHTML = `
            <button class='btn btn-sm btn-success' onclick='saveRequest(${requestId})'>Enregistrer</button>
            <button class='btn btn-sm btn-secondary' onclick='cancelEditRequest(${requestId})'>Annuler</button>
        `;
    }
    </script>
</body>
</html>
