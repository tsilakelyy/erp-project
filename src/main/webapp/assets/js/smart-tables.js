(function() {
    const STATUS_MAP = {
        BROUILLON: { level: 'warning', progress: 12, alert: 'Brouillon a finaliser.', hint: 'Completer les informations puis soumettre.' },
        DRAFT: { level: 'warning', progress: 12, alert: 'Brouillon a finaliser.', hint: 'Completer les informations puis soumettre.' },
        EN_ATTENTE: { level: 'warning', progress: 28, alert: 'En attente de validation.', hint: 'Prioriser la validation pour tenir les delais.' },
        A_VALIDER: { level: 'warning', progress: 30, alert: 'Validation requise.', hint: 'Verifier les pre-requis puis valider.' },
        EN_COURS: { level: 'info', progress: 45, alert: 'Traitement en cours.', hint: 'Surveiller les actions en cours.' },
        EN_PREPARATION: { level: 'info', progress: 55, alert: 'Preparation en cours.', hint: 'Confirmer la disponibilite des ressources.' },
        PLANIFIE: { level: 'info', progress: 20, alert: 'Operation planifiee.', hint: 'Verifier le calendrier et les moyens.' },
        VALIDEE: { level: 'success', progress: 62, alert: 'Validation obtenue.', hint: 'Passer a l etape suivante.' },
        APPROUVEE: { level: 'success', progress: 62, alert: 'Validation obtenue.', hint: 'Passer a l etape suivante.' },
        RECUE: { level: 'info', progress: 80, alert: 'Reception terminee.', hint: 'Preparer la facturation.' },
        RECUPEREE: { level: 'info', progress: 80, alert: 'Reception terminee.', hint: 'Preparer la facturation.' },
        FACTUREE: { level: 'success', progress: 95, alert: 'Facturation terminee.', hint: 'Verifier le paiement.' },
        PAYEE: { level: 'success', progress: 100, alert: 'Processus termine.', hint: 'Archiver et analyser les resultats.' },
        LIVREE: { level: 'success', progress: 90, alert: 'Livraison terminee.', hint: 'Confirmer la satisfaction client.' },
        EXPEDIEE: { level: 'info', progress: 75, alert: 'Expedition en cours.', hint: 'Suivre la livraison.' },
        CLOTURE: { level: 'success', progress: 100, alert: 'Dossier cloture.', hint: 'Cloturer et archiver.' },
        TERMINEE: { level: 'success', progress: 100, alert: 'Processus termine.', hint: 'Archiver et analyser les resultats.' },
        ACTIVE: { level: 'success', progress: 100, alert: 'Element actif.', hint: 'Suivi standard.' },
        ACTIF: { level: 'success', progress: 100, alert: 'Element actif.', hint: 'Suivi standard.' },
        INACTIVE: { level: 'danger', progress: 8, alert: 'Element inactif.', hint: 'Reactiver si necessaire.' },
        INACTIF: { level: 'danger', progress: 8, alert: 'Element inactif.', hint: 'Reactiver si necessaire.' },
        ANNULEE: { level: 'danger', progress: 5, alert: 'Operation annulee.', hint: 'Verifier la cause et relancer si besoin.' },
        REJETEE: { level: 'danger', progress: 5, alert: 'Operation rejetee.', hint: 'Corriger puis soumettre a nouveau.' }
    };

    function normalizeStatus(value) {
        if (!value) return '';
        return String(value)
            .trim()
            .toUpperCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .replace(/\s+/g, '_');
    }

    function getStatusInfo(status) {
        const key = normalizeStatus(status);
        return STATUS_MAP[key] || { level: 'info', progress: 35, alert: 'Suivi en cours.', hint: 'Verifier les prochaines actions.' };
    }

    function findStatusIndex(table) {
        const headers = Array.from(table.querySelectorAll('thead th'));
        for (let i = 0; i < headers.length; i++) {
            const label = headers[i].textContent.trim().toLowerCase();
            if (label.includes('statut') || label.includes('status')) {
                return i;
            }
        }
        return -1;
    }

    function extractStatusFromRow(row, statusIndex) {
        if (row.dataset && row.dataset.status) {
            return row.dataset.status;
        }
        if (statusIndex >= 0 && row.cells && row.cells[statusIndex]) {
            const cell = row.cells[statusIndex];
            const badge = cell.querySelector('.badge, .badge-status');
            if (badge) return badge.textContent.trim();
            return cell.textContent.trim();
        }
        return '';
    }

    function applyStatusBadges(table, statusIndex) {
        if (statusIndex < 0) return;
        const rows = table.querySelectorAll('tbody tr');
        rows.forEach(row => {
            const cell = row.cells[statusIndex];
            if (!cell) return;
            const existing = cell.querySelector('.badge-status');
            if (existing) return;
            const rawText = cell.textContent.trim();
            if (!rawText) return;
            const info = getStatusInfo(rawText);
            const existingBadge = cell.querySelector('.badge');
            if (existingBadge) {
                existingBadge.classList.add('badge-status', info.level);
                if (!cell.querySelector('.status-progress')) {
                    const progress = document.createElement('div');
                    progress.className = 'status-progress';
                    const bar = document.createElement('span');
                    bar.className = 'status-progress-bar';
                    bar.style.width = `${info.progress}%`;
                    progress.appendChild(bar);
                    cell.appendChild(progress);
                }
                return;
            }
            if (cell.querySelector('input, select, textarea, button')) {
                return;
            }
            cell.textContent = '';
            const badge = document.createElement('span');
            badge.className = `badge-status ${info.level}`;
            badge.textContent = rawText;
            cell.appendChild(badge);
            const progress = document.createElement('div');
            progress.className = 'status-progress';
            const bar = document.createElement('span');
            bar.className = 'status-progress-bar';
            bar.style.width = `${info.progress}%`;
            progress.appendChild(bar);
            cell.appendChild(progress);
        });
    }

    function collectStatuses(table, statusIndex) {
        const statuses = new Set();
        if (statusIndex < 0) return statuses;
        const rows = table.querySelectorAll('tbody tr');
        rows.forEach(row => {
            const status = extractStatusFromRow(row, statusIndex);
            if (status) statuses.add(status);
        });
        return statuses;
    }

    function parseAmountFromRow(row) {
        let best = 0;
        const cells = Array.from(row.cells || []);
        cells.forEach(cell => {
            const text = cell.textContent || '';
            const cleaned = text.replace(/[^0-9.,-]/g, '').replace(/,/g, '');
            const number = parseFloat(cleaned);
            if (!isNaN(number) && number > best) {
                best = number;
            }
        });
        return best;
    }

    function buildFilterBar(table, statusIndex) {
        const bar = document.createElement('div');
        bar.className = 'smart-filter-bar';

        const searchGroup = document.createElement('div');
        const searchLabel = document.createElement('label');
        searchLabel.textContent = 'Recherche';
        const searchInput = document.createElement('input');
        searchInput.type = 'text';
        searchInput.placeholder = 'Rechercher...';
        searchGroup.appendChild(searchLabel);
        searchGroup.appendChild(searchInput);

        bar.appendChild(searchGroup);

        let statusSelect = null;
        if (statusIndex >= 0) {
            const statusGroup = document.createElement('div');
            const statusLabel = document.createElement('label');
            statusLabel.textContent = 'Statut';
            statusSelect = document.createElement('select');
            const optionAll = document.createElement('option');
            optionAll.value = '';
            optionAll.textContent = 'Tous';
            statusSelect.appendChild(optionAll);
            statusGroup.appendChild(statusLabel);
            statusGroup.appendChild(statusSelect);
            bar.appendChild(statusGroup);
        }

        const actionGroup = document.createElement('div');
        actionGroup.className = 'smart-filter-actions';
        const resetBtn = document.createElement('button');
        resetBtn.type = 'button';
        resetBtn.className = 'btn btn-secondary btn-sm';
        resetBtn.textContent = 'Reinitialiser';
        actionGroup.appendChild(resetBtn);
        bar.appendChild(actionGroup);

        function refreshStatusOptions() {
            if (!statusSelect) return;
            const current = statusSelect.value;
            statusSelect.innerHTML = '';
            const option = document.createElement('option');
            option.value = '';
            option.textContent = 'Tous';
            statusSelect.appendChild(option);
            collectStatuses(table, statusIndex).forEach(status => {
                const opt = document.createElement('option');
                opt.value = status;
                opt.textContent = status;
                statusSelect.appendChild(opt);
            });
            statusSelect.value = current;
        }

        function applyFilters() {
            const query = (searchInput.value || '').toLowerCase();
            const statusValue = statusSelect ? statusSelect.value : '';
            const rows = Array.from(table.querySelectorAll('tbody tr'));
            rows.forEach(row => {
                const rowText = row.textContent.toLowerCase();
                const statusText = normalizeStatus(extractStatusFromRow(row, statusIndex));
                const statusMatch = statusValue ? statusText === normalizeStatus(statusValue) : true;
                const queryMatch = query ? rowText.includes(query) : true;
                row.style.display = (statusMatch && queryMatch) ? '' : 'none';
            });
        }

        searchInput.addEventListener('input', applyFilters);
        if (statusSelect) statusSelect.addEventListener('change', applyFilters);
        resetBtn.addEventListener('click', () => {
            searchInput.value = '';
            if (statusSelect) statusSelect.value = '';
            applyFilters();
        });

        refreshStatusOptions();

        return { bar, refreshStatusOptions };
    }

    function findCreateLink(container) {
        if (!container) return null;
        const buttons = container.querySelectorAll('a[href]');
        for (const btn of buttons) {
            if (btn.closest('table')) continue;
            const href = btn.getAttribute('href');
            const label = (btn.textContent || '').trim();
            const lower = label.toLowerCase();
            if (href && (href.includes('/new') || href.includes('/form') || lower.includes('nouvelle') || lower.includes('ajouter') || lower.includes('creer'))) {
                return { href, label: label || 'Creer' };
            }
        }
        return null;
    }

    function extractRowLinks(row) {
        const links = Array.from(row.querySelectorAll('a[href]'));
        const result = {};
        links.forEach(link => {
            const label = link.textContent.trim().toLowerCase();
            const href = link.getAttribute('href');
            if (!href) return;
            if (!result.view && (label.includes('voir') || label.includes('detail') || label.includes('consulter'))) {
                result.view = { href, label: link.textContent.trim() };
            }
            if (!result.edit && (label.includes('modifier') || label.includes('editer') || href.includes('/edit') || href.includes('/form'))) {
                result.edit = { href, label: link.textContent.trim() };
            }
            if (!result.delete && (label.includes('supprimer') || label.includes('delete'))) {
                result.delete = { href, label: link.textContent.trim() };
            }
        });
        return result;
    }

    function extractRowForms(row) {
        const forms = Array.from(row.querySelectorAll('form'));
        return forms.map(form => ({
            form,
            label: (form.querySelector('button') ? form.querySelector('button').textContent.trim() : 'Valider')
        }));
    }

    function extractRowButtons(row) {
        return Array.from(row.querySelectorAll('button'))
            .filter(btn => !btn.closest('form'))
            .filter(btn => btn.textContent && btn.textContent.trim().length > 0);
    }

    function guessActionStyle(label) {
        const text = (label || '').toLowerCase();
        if (text.includes('supprimer') || text.includes('delete')) return 'danger';
        if (text.includes('valider') || text.includes('confirmer')) return 'success';
        if (text.includes('modifier') || text.includes('editer')) return 'warning';
        if (text.includes('voir') || text.includes('detail') || text.includes('consulter')) return 'secondary';
        return 'primary';
    }

    function computeTableSummary(table, statusIndex) {
        const rows = Array.from(table.querySelectorAll('tbody tr'))
            .filter(row => row.style.display !== 'none');
        let total = 0;
        let pending = 0;
        let complete = 0;
        let amountSum = 0;
        let progressSum = 0;

        rows.forEach(row => {
            total += 1;
            const statusText = extractStatusFromRow(row, statusIndex);
            const info = getStatusInfo(statusText);
            progressSum += info.progress;
            if (info.progress >= 90 || info.level === 'success') {
                complete += 1;
            } else {
                pending += 1;
            }
            amountSum += parseAmountFromRow(row);
        });

        const avgProgress = total ? Math.round(progressSum / total) : 0;
        const avgAmount = total ? Math.round(amountSum / total) : 0;
        return { total, pending, complete, avgProgress, avgAmount };
    }

    function buildPanel() {
        const panel = document.createElement('aside');
        panel.className = 'smart-table-panel';
        panel.innerHTML = `
            <div class="panel-title">Suivi et actions</div>
            <div class="smart-metrics"></div>
            <div class="smart-progress"><div class="smart-progress-bar"></div></div>
            <div class="smart-progress-label">Avancement: 0%</div>
            <div class="smart-actions"></div>
            <div class="smart-alert warning">Selectionnez une ligne pour voir le detail.</div>
            <div class="smart-hints">
                <h4>Aide a la decision</h4>
                <div class="smart-metrics smart-hints-list"></div>
            </div>
        `;
        return panel;
    }

    function updatePanel(panel, row, statusIndex, createLink, table) {
        const metrics = panel.querySelector('.smart-metrics');
        const progressBar = panel.querySelector('.smart-progress-bar');
        const progressLabel = panel.querySelector('.smart-progress-label');
        const actions = panel.querySelector('.smart-actions');
        const alertBox = panel.querySelector('.smart-alert');
        const hintsList = panel.querySelector('.smart-hints-list');

        if (!row) {
            const summary = table ? computeTableSummary(table, statusIndex) : null;
            actions.innerHTML = '';
            hintsList.innerHTML = '';

            if (summary && summary.total > 0) {
                metrics.innerHTML = `
                    <div><strong>Lignes:</strong> ${summary.total}</div>
                    <div><strong>Completes:</strong> ${summary.complete}</div>
                    <div><strong>En attente:</strong> ${summary.pending}</div>
                    <div><strong>Panier moyen:</strong> Ar ${summary.avgAmount.toLocaleString('fr-FR')}</div>
                `;
                progressBar.style.width = `${summary.avgProgress}%`;
                progressLabel.textContent = `Avancement global: ${summary.avgProgress}%`;
                if (summary.pending > 0) {
                    alertBox.className = 'smart-alert warning';
                    alertBox.textContent = `${summary.pending} dossier(s) en attente de traitement.`;
                } else {
                    alertBox.className = 'smart-alert success';
                    alertBox.textContent = 'Tout est a jour. Aucun retard detecte.';
                }
                hintsList.innerHTML = `<div>Priorisez les elements au statut EN_ATTENTE.</div>`;
            } else {
                metrics.innerHTML = '';
                progressBar.style.width = '0%';
                progressLabel.textContent = 'Avancement: 0%';
                alertBox.className = 'smart-alert warning';
                alertBox.textContent = 'Selectionnez une ligne pour voir le detail.';
            }

            if (createLink) {
                const link = document.createElement('a');
                link.className = 'btn btn-primary btn-sm';
                link.href = createLink.href;
                link.textContent = createLink.label || 'Creer';
                actions.appendChild(link);
            }
            return;
        }

        const statusText = extractStatusFromRow(row, statusIndex);
        const info = getStatusInfo(statusText);
        const amount = parseAmountFromRow(row);

        metrics.innerHTML = `
            <div><strong>Statut:</strong> ${statusText || '-'}</div>
            <div><strong>Montant:</strong> ${amount ? ('Ar ' + amount.toLocaleString('fr-FR')) : '-'}</div>
        `;

        progressBar.style.width = `${info.progress}%`;
        progressLabel.textContent = `Avancement: ${info.progress}%`;

        alertBox.className = `smart-alert ${info.level}`;
        alertBox.textContent = info.alert;

        actions.innerHTML = '';
        const actionLabels = new Set();
        if (createLink) {
            const link = document.createElement('a');
            link.className = 'btn btn-primary btn-sm';
            link.href = createLink.href;
            link.textContent = createLink.label || 'Creer';
            actions.appendChild(link);
            actionLabels.add(link.textContent.trim().toLowerCase());
        }

        const rowLinks = extractRowLinks(row);
        if (rowLinks.view) {
            const view = document.createElement('a');
            view.className = 'btn btn-secondary btn-sm';
            view.href = rowLinks.view.href;
            view.textContent = rowLinks.view.label || 'Voir';
            actions.appendChild(view);
            actionLabels.add(view.textContent.trim().toLowerCase());
        }
        if (rowLinks.edit) {
            const edit = document.createElement('a');
            edit.className = 'btn btn-warning btn-sm';
            edit.href = rowLinks.edit.href;
            edit.textContent = rowLinks.edit.label || 'Modifier';
            actions.appendChild(edit);
            actionLabels.add(edit.textContent.trim().toLowerCase());
        }
        if (rowLinks.delete) {
            const del = document.createElement('a');
            del.className = 'btn btn-danger btn-sm';
            del.href = rowLinks.delete.href;
            del.textContent = rowLinks.delete.label || 'Supprimer';
            actions.appendChild(del);
            actionLabels.add(del.textContent.trim().toLowerCase());
        }

        const rowForms = extractRowForms(row);
        rowForms.forEach(item => {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'btn btn-success btn-sm';
            btn.textContent = item.label || 'Valider';
            btn.addEventListener('click', () => item.form.submit());
            actions.appendChild(btn);
            actionLabels.add(btn.textContent.trim().toLowerCase());
        });

        const rowButtons = extractRowButtons(row);
        rowButtons.forEach(button => {
            const label = button.textContent.trim();
            if (!label) return;
            const key = label.toLowerCase();
            if (actionLabels.has(key)) return;
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = `btn btn-${guessActionStyle(label)} btn-sm`;
            btn.textContent = label;
            btn.addEventListener('click', () => button.click());
            actions.appendChild(btn);
            actionLabels.add(key);
        });

        hintsList.innerHTML = '';
        hintsList.innerHTML += `<div>${info.hint}</div>`;
        if (amount > 1000000) {
            hintsList.innerHTML += '<div>Montant eleve: validation direction probable.</div>';
        }
        if (normalizeStatus(statusText) === 'EN_ATTENTE') {
            hintsList.innerHTML += '<div>Verifier la disponibilite des ressources avant validation.</div>';
        }
    }

    function initTable(table) {
        if (!table || table.dataset.smartInit === '1') return;
        table.dataset.smartInit = '1';

        const statusIndex = findStatusIndex(table);
        applyStatusBadges(table, statusIndex);

        const parent = table.parentElement;
        if (!parent) return;

        const wrapper = document.createElement('div');
        wrapper.className = 'smart-table-wrap';
        const main = document.createElement('div');
        main.className = 'smart-table-main';
        const panel = buildPanel();

        parent.insertBefore(wrapper, table);
        wrapper.appendChild(main);
        main.appendChild(table);
        wrapper.appendChild(panel);

        const { bar, refreshStatusOptions } = buildFilterBar(table, statusIndex);
        main.insertBefore(bar, table);

        const mainContent = table.closest('.main-content');
        const createLink = findCreateLink(mainContent);
        updatePanel(panel, null, statusIndex, createLink, table);

        let activeRow = null;
        table.addEventListener('click', (event) => {
            const row = event.target.closest('tbody tr');
            if (!row) return;
            if (activeRow) activeRow.classList.remove('smart-row-active');
            activeRow = row;
            row.classList.add('smart-row-active');
            updatePanel(panel, row, statusIndex, createLink, table);
        });

        let refreshPending = false;
        const scheduleRefresh = () => {
            if (refreshPending) return;
            refreshPending = true;
            window.requestAnimationFrame(() => {
                refreshPending = false;
                applyStatusBadges(table, statusIndex);
                refreshStatusOptions();
                updatePanel(panel, activeRow, statusIndex, createLink, table);
            });
        };

        const observer = new MutationObserver(scheduleRefresh);
        const tbody = table.querySelector('tbody');
        if (tbody) {
            observer.observe(tbody, { childList: true, subtree: true });
        }
    }

    function initSmartTables() {
        const tables = document.querySelectorAll('.main-content table');
        tables.forEach(table => {
            if (table.classList.contains('no-smart') || table.dataset.smart === 'false') return;
            initTable(table);
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSmartTables);
    } else {
        initSmartTables();
    }

    window.SmartTable = {
        normalizeStatus,
        getStatusInfo,
        findStatusIndex,
        extractStatusFromRow,
        parseAmountFromRow,
        computeTableSummary
    };
})();
