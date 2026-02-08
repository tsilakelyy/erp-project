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
                <h1><c:if test="${pricingList.id != null}">Modifier</c:if><c:if test="${pricingList.id == null}">Nouvelle</c:if> Liste de Prix</h1>
                <a href="<c:url value='/admin/pricing-lists'/>" class="btn btn-secondary">Retour</a>
            </div>

            <div class="form-card">
                <c:set var="formAction">
                    <c:choose>
                        <c:when test="${pricingList.id != null}">/admin/pricing-lists/${pricingList.id}</c:when>
                        <c:otherwise>/admin/pricing-lists</c:otherwise>
                    </c:choose>
                </c:set>
                <form method="POST" action="<c:url value='${formAction}'/>">
                    <c:if test="${pricingList.id != null}">
                        <input type="hidden" name="id" value="${pricingList.id}"/>
                    </c:if>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label>Code *</label>
                            <c:choose>
                                <c:when test="${pricingList.id != null}">
                                    <input type="text" class="form-control" value="${pricingList.code}" readonly>
                                    <input type="hidden" name="code" value="${pricingList.code}">
                                </c:when>
                                <c:otherwise>
                                    <input type="text" name="code" class="form-control" value="${pricingList.code}" required>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label>Type *</label>
                            <select name="typeListe" class="form-control" required>
                                <option value="">-- Sélectionner --</option>
                                <option value="VENTE" <c:if test="${pricingList.typeListe == 'VENTE'}">selected</c:if>>Vente</option>
                                <option value="ACHAT" <c:if test="${pricingList.typeListe == 'ACHAT'}">selected</c:if>>Achat</option>
                                <option value="GENERAL" <c:if test="${pricingList.typeListe == 'GENERAL'}">selected</c:if>>Général</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Libellé *</label>
                        <input type="text" name="libelle" class="form-control" value="${pricingList.libelle}" required>
                    </div>

                    <div class="form-group">
                        <label>Description</label>
                        <textarea name="description" class="form-control" rows="4">${pricingList.description}</textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label>Date Début *</label>
                            <input type="datetime-local" name="dateDebut" class="form-control" value="${pricingList.dateDebut}" required>
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label>Date Fin</label>
                            <input type="datetime-local" name="dateFin" class="form-control" value="${pricingList.dateFin}">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label>Devise</label>
                            <input type="text" name="devise" class="form-control" value="${pricingList.devise}" maxlength="10">
                        </div>
                    </div>

                    <div style="border-top: 1px solid #ddd; padding-top: 20px; margin-top: 20px;">
                        <label class="checkbox-label">
                            <input type="hidden" name="actif" value="false">
                            <input type="checkbox" name="actif" value="true" <c:if test="${pricingList.actif}">checked</c:if>> Actif
                        </label>
                        <label class="checkbox-label">
                            <input type="hidden" name="parDefaut" value="false">
                            <input type="checkbox" name="parDefaut" value="true" <c:if test="${pricingList.parDefaut}">checked</c:if>> Défaut pour ce type
                        </label>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Enregistrer</button>
                        <a href="<c:url value='/admin/pricing-lists'/>" class="btn btn-secondary">Annuler</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>
</body>
</html>
