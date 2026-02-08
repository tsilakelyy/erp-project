<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nouvelle demande - Client</title>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-client.css'/>">
</head>
<body class="client-portal client-page">
    <c:set var="pageActive" value="requests"/>
    <jsp:include page="/WEB-INF/jsp/client/partials/nav.jsp"/>

    <main class="client-shell">
        <section class="client-hero" style="grid-template-columns: 1fr;">
            <div>
                <h1>Nouvelle demande client</h1>
                <p>Precisez votre besoin: livraison, bon de reduction, bon d'achat ou devis produit.</p>
            </div>
        </section>

        <section class="client-section">
            <h2>Formulaire de demande</h2>
            <c:if test="${not empty param.error}">
                <div class="client-action-card" style="margin-bottom: 12px;">
                    <c:out value="${param.error}"/>
                </div>
            </c:if>

            <form method="POST" action="<c:url value='/client/requests'/>">
                <label class="client-input-label" for="requestType">Type de demande</label>
                <select class="client-input" id="requestType" name="requestType" required>
                    <option value="">Selectionner un type</option>
                    <option value="COMMANDE" ${requestType == 'COMMANDE' ? 'selected' : ''}>Commande</option>
                    <option value="LIVRAISON" ${requestType == 'LIVRAISON' ? 'selected' : ''}>Demande de livraison</option>
                    <option value="BON_REDUCTION" ${requestType == 'BON_REDUCTION' ? 'selected' : ''}>Bon de reduction</option>
                    <option value="BON_ACHAT" ${requestType == 'BON_ACHAT' ? 'selected' : ''}>Bon d'achat</option>
                    <option value="DEVIS" ${requestType == 'DEVIS' ? 'selected' : ''}>Demande de devis</option>
                    <option value="PRODUIT" ${requestType == 'PRODUIT' ? 'selected' : ''}>Demande produit</option>
                </select>

                <label class="client-input-label" id="titleLabel" for="titre">Titre de la demande</label>
                <input class="client-input" id="titre" name="titre" type="text" placeholder="Ex: Livraison urgente zone nord" required>

                <label class="client-input-label" for="articleId">Article concerne</label>
                <select class="client-input" id="articleId" name="articleId">
                    <option value="">Selectionner un article</option>
                    <c:forEach items="${articles}" var="article">
                        <option value="${article.id}" ${articleId == article.id ? 'selected' : ''}>
                            <c:out value="${article.libelle}"/> (<c:out value="${article.code}"/>)
                        </option>
                    </c:forEach>
                </select>

                <div class="client-form-grid">
                    <div>
                        <label class="client-input-label" for="quantite">Quantite</label>
                        <input class="client-input" id="quantite" name="quantite" type="number" step="0.01" placeholder="0">
                    </div>
                    <div>
                        <label class="client-input-label" id="amountLabel" for="montantEstime">Montant estime (Ar)</label>
                        <input class="client-input" id="montantEstime" name="montantEstime" type="number" step="0.01" placeholder="0">
                    </div>
                </div>

                <label class="client-input-label" id="descriptionLabel" for="description">Description / consignes</label>
                <textarea class="client-input" id="description" name="description" rows="4" placeholder="Ajoutez les informations utiles a votre equipe commerciale"></textarea>

                <div class="client-action-card" id="requestHint" style="margin-bottom: 16px;">
                    Ajoutez le maximum d'informations pour accelerer la prise en charge.
                </div>

                <button class="client-button" type="submit">Envoyer la demande</button>
                <a class="client-link" href="<c:url value='/client/requests'/>">Retour aux demandes</a>
            </form>
        </section>

        <div class="client-footer">Vos demandes sont traitees par l'equipe back office.</div>
    </main>

    <script>
        (function() {
            const typeField = document.getElementById('requestType');
            const titleLabel = document.getElementById('titleLabel');
            const amountLabel = document.getElementById('amountLabel');
            const descLabel = document.getElementById('descriptionLabel');
            const hint = document.getElementById('requestHint');

            function updateLabels() {
                const type = (typeField.value || '').toUpperCase();
                if (type === 'BON_REDUCTION') {
                    titleLabel.textContent = 'Reference du bon de reduction';
                    amountLabel.textContent = 'Valeur du bon (Ar)';
                    descLabel.textContent = 'Conditions du bon';
                    hint.textContent = 'Indiquez les conditions d\'utilisation et la duree de validite.';
                    return;
                }
                if (type === 'BON_ACHAT') {
                    titleLabel.textContent = 'Titre du bon d\'achat';
                    amountLabel.textContent = 'Valeur du bon (Ar)';
                    descLabel.textContent = 'Conditions du bon';
                    hint.textContent = 'Precisez le budget, la duree et les categories concernees.';
                    return;
                }
                if (type === 'LIVRAISON') {
                    titleLabel.textContent = 'Adresse ou point de livraison';
                    amountLabel.textContent = 'Budget logistique (Ar)';
                    descLabel.textContent = 'Consignes de livraison';
                    hint.textContent = 'Precisez date, lieu, contact et consignes de livraison.';
                    return;
                }
                if (type === 'DEVIS') {
                    titleLabel.textContent = 'Objet du devis';
                    amountLabel.textContent = 'Budget cible (Ar)';
                    descLabel.textContent = 'Precisions sur le devis';
                    hint.textContent = 'Detaillez vos attentes pour accelerer la preparation du proforma.';
                    return;
                }
                if (type === 'PRODUIT') {
                    titleLabel.textContent = 'Produit souhaite';
                    amountLabel.textContent = 'Budget estime (Ar)';
                    descLabel.textContent = 'Details du produit';
                    hint.textContent = 'Precisez dimensions, quantites et contraintes techniques.';
                    return;
                }
                titleLabel.textContent = 'Titre de la demande';
                amountLabel.textContent = 'Montant estime (Ar)';
                descLabel.textContent = 'Description / consignes';
                hint.textContent = 'Ajoutez le maximum d\'informations pour accelerer la prise en charge.';
            }

            typeField.addEventListener('change', updateLabels);
            updateLabels();
        })();
    </script>
</body>
</html>
