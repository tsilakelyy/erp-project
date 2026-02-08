<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Commande d'achat - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1" id="pageTitle">ERP - Nouvelle commande d'achat</span>
    </nav>

    <div class="container mt-4">
        <div class="row">
            <div class="col-md-8">
                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger" id="formError" data-error="<c:out value='${param.error}'/>"></div>
                    <script>
                        (function() {
                            var el = document.getElementById('formError');
                            if (!el) return;
                            var raw = el.getAttribute('data-error') || '';
                            try {
                                el.textContent = decodeURIComponent(raw.replace(/\\+/g, ' '));
                            } catch (e) {
                                el.textContent = raw;
                            }
                        })();
                    </script>
                </c:if>
                <form method="POST" action="<c:url value='/purchases/orders/form'/>">
                    <input type="hidden" id="orderId" name="id" value="<c:out value='${order.id}'/>">
                    
                    <div class="mb-3">
                        <label for="proformaId" class="form-label">Proforma validee *</label>
                        <select class="form-select" id="proformaId" name="proformaId" required>
                            <option value="">Selectionner (obligatoire)</option>
                            <c:forEach items="${proformas}" var="pf">
                                <option value="${pf.id}"
                                        data-fournisseur="${pf.fournisseurId}"
                                        data-entrepot="${pf.entrepotId}"
                                        data-montant="${pf.montantHt}"
                                        data-tva="${pf.tauxTva}">
                                    ${pf.numero} - ${pf.statut}
                                </option>
                            </c:forEach>
                        </select>
                        <div class="form-text">Le bon de commande doit venir d'une proforma validee. Les champs sont pre-remplis.</div>
                    </div>

                    <div class="mb-3">
                        <label for="fournisseurId" class="form-label">Fournisseur</label>
                        <select class="form-select" id="fournisseurId" name="fournisseurId" required>
                            <option value="">Selectionner</option>
                            <c:forEach items="${suppliers}" var="supplier">
                                <option value="${supplier.id}">${supplier.nomEntreprise}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="entrepotId" class="form-label">Entrepot</label>
                        <select class="form-select" id="entrepotId" name="entrepotId" required>
                            <option value="">Selectionner</option>
                            <c:forEach items="${warehouses}" var="wh">
                                <option value="${wh.id}">
                                    <c:out value="${wh.code}"/> - <c:out value="${wh.nomDepot}"/> (<c:out value="${wh.ville}"/>)
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="montantHt" class="form-label">Montant HT (Ar)</label>
                        <input type="number" class="form-control" id="montantHt" name="montantHt" step="0.01">
                    </div>

                    <div class="mb-3">
                        <label for="tauxTva" class="form-label">Taux TVA (%)</label>
                        <input type="number" class="form-control" id="tauxTva" name="tauxTva" step="0.01" value="20.00">
                    </div>

                    <div class="mb-3">
                        <button type="submit" class="btn btn-primary" id="submitBtn">Creer</button>
                        <a href="<c:url value='/purchases/orders'/>" class="btn btn-secondary">Annuler</a>
                    </div>
                    <input type="hidden" name="_csrf" value="${_csrf.token}" />
                </form>
            </div>
        </div>
    </div>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Load order data if ID is provided
            const orderId = new URLSearchParams(window.location.search).get('id');
            if (orderId) {
                loadOrder(orderId);
            }

            var proformaSelect = document.getElementById('proformaId');
            if (proformaSelect) {
                proformaSelect.addEventListener('change', function() {
                    var option = proformaSelect.options[proformaSelect.selectedIndex];
                    if (!option || !option.value) return;
                    var fournisseur = option.getAttribute('data-fournisseur');
                    var entrepot = option.getAttribute('data-entrepot');
                    var montant = option.getAttribute('data-montant');
                    var tva = option.getAttribute('data-tva');

                    if (fournisseur) document.getElementById('fournisseurId').value = fournisseur;
                    if (entrepot) document.getElementById('entrepotId').value = entrepot;
                    if (montant) document.getElementById('montantHt').value = montant;
                    if (tva) document.getElementById('tauxTva').value = tva;
                });
            }
        });

        function loadOrder(id) {
            ajaxCall(APP_CONTEXT + '/purchases/orders/api/' + id, 'GET', null,
                function(order) {
                    document.getElementById('pageTitle').textContent = 'ERP - Modifier commande d\'achat';
                    document.getElementById('orderId').value = order.id;
                    document.getElementById('fournisseurId').value = order.fournisseurId || '';
                    document.getElementById('entrepotId').value = order.entrepotId || '';
                    document.getElementById('montantHt').value = order.montantHt || '';
                    document.getElementById('tauxTva').value = order.tauxTva || '20.00';
                    document.getElementById('submitBtn').textContent = 'Modifier';
                },
                function() { 
                    console.error('Error loading order data');
                }
            );
        }
    </script>
    </div>
</body>
</html>
