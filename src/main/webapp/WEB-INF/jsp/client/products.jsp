<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catalogue produits - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="products"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero">
            <div>
                <h1>Catalogue produits</h1>
                <p>Choisissez vos articles et lancez des demandes de devis, commandes ou bons selon vos besoins.</p>
            </div>
            <div class="client-hero-card">
                <div style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.6px;">Articles disponibles</div>
                <div style="font-size: 24px; font-weight: 700; margin-top: 6px;">
                    <c:out value="${fn:length(articles)}"/>
                </div>
                <div style="margin-top: 10px; font-size: 12px;">Mis a jour en temps reel</div>
            </div>
        </section>

        <section class="client-section">
            <div class="client-section-header">
                <h2>Actions express</h2>
                <div class="client-section-actions">
                    <a class="client-link" href="<c:url value='/client/requests/new?type=BON_REDUCTION'/>">Bon de reduction</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=BON_ACHAT'/>">Bon d'achat</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=DEVIS'/>">Demander un devis</a>
                </div>
            </div>
            <div class="client-actions">
                <a class="client-action-card" href="<c:url value='/client/orders/new'/>">
                    Faire une commande
                    <span>Initier une commande directe et suivre la validation</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/requests/new?type=LIVRAISON'/>">
                    Demander une livraison
                    <span>Planifier une expedition ou une re-livraison</span>
                </a>
                <a class="client-action-card" href="<c:url value='/client/requests/new?type=PRODUIT'/>">
                    Demander un produit
                    <span>Exprimer un besoin specifique ou une reference manquante</span>
                </a>
            </div>
        </section>

        <section class="client-section">
            <div class="client-section-header">
                <h2>Selection produits</h2>
                <div class="client-section-actions">
                    <a class="client-link" href="<c:url value='/client/requests/new?type=DEVIS'/>">Demande groupage</a>
                    <a class="client-link" href="<c:url value='/client/requests/new?type=BON_ACHAT'/>">Utiliser un bon</a>
                </div>
            </div>

            <!-- Filtrage & Recherche -->
            <div class="client-filter-panel">
                <form method="get" action="<c:url value='/client/products'/>" class="client-filters-form">
                    <div class="filters-row">
                        <div class="filter-group">
                            <label for="search">Recherche</label>
                            <input type="text" id="search" name="search" class="form-control" 
                                   placeholder="Code, libellé ou description..." 
                                   value="${filterSearch}">
                        </div>
                        
                        <div class="filter-group">
                            <label for="categoryId">Catégorie</label>
                            <select id="categoryId" name="categoryId" class="form-control">
                                <option value="">-- Toutes les catégories --</option>
                                <c:forEach items="${categories}" var="cat">
                                    <option value="${cat.id}" 
                                            <c:if test="${cat.id == filterCategoryId}">selected</c:if>>
                                        ${cat.libelle}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="priceMin">Prix min (Ar)</label>
                            <input type="number" id="priceMin" name="priceMin" class="form-control" 
                                   placeholder="0" step="0.01"
                                   value="${filterPriceMin}">
                        </div>
                        
                        <div class="filter-group">
                            <label for="priceMax">Prix max (Ar)</label>
                            <input type="number" id="priceMax" name="priceMax" class="form-control" 
                                   placeholder="999999" step="0.01"
                                   value="${filterPriceMax}">
                        </div>
                        
                        <div class="filter-actions">
                            <button type="submit" class="btn btn-primary">Filtrer</button>
                            <a href="<c:url value='/client/products'/>" class="btn btn-secondary">Réinitialiser</a>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Résultats -->
            <div class="products-info">
                <p><strong>${fn:length(articles)}</strong> article(s) trouvé(s)</p>
            </div>

            <div class="client-products-grid">
                <c:forEach items="${articles}" var="article">
                    <div class="product-card">
                        <div class="product-card-header">
                            <span class="client-badge">Code: <c:out value="${article.code}"/></span>
                            <span><c:out value="${article.uniteMesure != null ? article.uniteMesure : 'Unite'}"/></span>
                        </div>
                        <h3><c:out value="${article.libelle}"/></h3>
                        <div class="product-description">
                            <c:choose>
                                <c:when test="${not empty article.description}">
                                    <c:out value="${article.description}"/>
                                </c:when>
                                <c:otherwise>Description a completer par votre equipe.</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="product-meta">
                            <div>TVA: <c:out value="${article.tauxTva}"/>%</div>
                            <div>Min: <c:out value="${article.quantiteMinimale}"/></div>
                            <c:if test="${article.quantiteMaximale != null}">
                                <div>Max: <c:out value="${article.quantiteMaximale}"/></div>
                            </c:if>
                        </div>
                        <div class="product-price">Ar <c:out value="${article.prixUnitaire}"/></div>
                        <div class="product-actions">
                            <a class="client-link" href="<c:url value='/client/orders/new'/>">Commander</a>
                            <a class="client-link" href="<c:url value='/client/requests/new?type=DEVIS&articleId=${article.id}'/>">Demander devis</a>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty articles}">
                    <div class="client-action-card">
                        Aucun produit actif pour le moment. Contactez votre equipe commerciale.
                    </div>
                </c:if>
            </div>
        </section>

        <div class="client-footer">Besoin d'une reference introuvable ? Utilisez le formulaire de demande produit.</div>
    </main>
</body>
</html>
