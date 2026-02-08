(function() {
    const MODAL_ID = 'row-detail-modal';
    const BODY_BLUR_CLASS = 'modal-open';

    function ensureModal() {
        let modal = document.getElementById(MODAL_ID);
        if (modal) return modal;

        modal = document.createElement('div');
        modal.id = MODAL_ID;
        modal.className = 'modal modal-row';
        modal.innerHTML =
            '<div class="modal-content">' +
            '  <div class="modal-header">' +
            '    <h3>Options</h3>' +
            '    <button class="modal-close" type="button" aria-label="Fermer">&times;</button>' +
            '  </div>' +
            '  <div class="modal-body">' +
            '    <div class="modal-summary"></div>' +
            '    <div class="modal-details"></div>' +
            '  </div>' +
            '  <div class="modal-footer modal-actions"></div>' +
            '</div>';

        document.body.appendChild(modal);

        modal.addEventListener('click', function(event) {
            if (event.target === modal) {
                closeModal();
            }
        });

        const closeBtn = modal.querySelector('.modal-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', closeModal);
        }

        return modal;
    }

    function closeModal() {
        const modal = document.getElementById(MODAL_ID);
        if (!modal) return;
        modal.style.display = 'none';
        modal.classList.remove('show');
        document.body.classList.remove(BODY_BLUR_CLASS);
    }

    function titleCase(value) {
        const text = (value || '').trim();
        if (!text) return '';
        return text.charAt(0).toUpperCase() + text.slice(1);
    }

    function getTableHeaders(table) {
        if (!table) return [];
        return Array.from(table.querySelectorAll('thead th')).map(th => th.textContent.trim());
    }

    function isActionHeader(label) {
        if (!label) return false;
        const lowered = label.toLowerCase();
        return lowered.includes('action') || lowered.includes('operations') || lowered.includes('option');
    }

    function findActionColumnIndex(table) {
        if (!table) return -1;
        const headers = table.querySelectorAll('thead th');
        for (let i = 0; i < headers.length; i++) {
            const label = headers[i].textContent.trim().toLowerCase();
            if (label.includes('action') || label.includes('options') || label.includes('operation')) {
                return i;
            }
        }
        return -1;
    }

    function ensureOptionsButtons(root) {
        const scope = root || document;
        const tables = scope.querySelectorAll('.main-content table');
        tables.forEach(table => {
            const index = findActionColumnIndex(table);
            if (index < 0) return;
            const header = table.querySelectorAll('thead th')[index];
            if (header) header.textContent = 'Options';

            const rows = table.querySelectorAll('tbody tr');
            rows.forEach(row => {
                const cell = row.cells[index];
                if (!cell || cell.querySelector('.btn-options')) return;

                const wrapper = document.createElement('div');
                wrapper.className = 'table-actions-hidden';
                while (cell.firstChild) {
                    wrapper.appendChild(cell.firstChild);
                }
                cell.appendChild(wrapper);

                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'btn btn-sm btn-secondary btn-options';
                btn.textContent = 'Options';
                btn.setAttribute('data-row-view', '1');
                cell.appendChild(btn);
            });
        });
    }

    function extractRowDetails(row) {
        const table = row.closest('table');
        const headers = getTableHeaders(table);
        const cells = Array.from(row.cells || []);
        const items = [];

        cells.forEach((cell, idx) => {
            const header = headers[idx] || 'Champ ' + (idx + 1);
            if (isActionHeader(header)) return;
            if (cell.querySelector('button, a, form, input, select, textarea')) {
                if (isActionHeader(header)) return;
                if (cell.querySelector('button, a, form')) return;
            }
            const value = cell.textContent.trim();
            if (!value && value !== '0') return;
            items.push({ label: header, value: value || '-' });
        });

        return items;
    }

    function findEditLink(row) {
        const links = Array.from(row.querySelectorAll('a[href]'));
        for (const link of links) {
            const label = (link.textContent || '').trim().toLowerCase();
            const href = link.getAttribute('href') || '';
            if (label.includes('modifier') || label.includes('editer') || label.includes('edit') || href.includes('/edit') || href.includes('/form')) {
                return link;
            }
        }
        return null;
    }

    function findDeleteForm(row) {
        const forms = Array.from(row.querySelectorAll('form'));
        for (const form of forms) {
            const btn = form.querySelector('button');
            const label = btn ? btn.textContent.trim().toLowerCase() : '';
            if (label.includes('supprimer') || label.includes('delete') || label.includes('desactiver') || label.includes('annuler')) {
                return { form: form, label: btn ? btn.textContent.trim() : 'Supprimer' };
            }
        }
        return null;
    }

    function findViewLink(row) {
        const links = Array.from(row.querySelectorAll('a[href]'));
        for (const link of links) {
            const label = (link.textContent || '').trim().toLowerCase();
            if (label.includes('voir') || label.includes('detail') || label.includes('consulter')) {
                return link;
            }
        }
        return null;
    }

    function buildDetailsHtml(items) {
        if (!items || items.length === 0) {
            return '<div class="modal-empty">Aucune information disponible</div>';
        }
        let html = '<div class="modal-detail-grid">';
        items.forEach(item => {
            html += '<div class="modal-detail-item">' +
                '<div class="modal-detail-label">' + titleCase(item.label) + '</div>' +
                '<div class="modal-detail-value">' + (item.value || '-') + '</div>' +
                '</div>';
        });
        html += '</div>';
        return html;
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

    function computeSummary(table) {
        if (window.SmartTable && window.SmartTable.computeTableSummary) {
            return window.SmartTable.computeTableSummary(table);
        }
        const rows = Array.from(table.querySelectorAll('tbody tr'))
            .filter(row => row.style.display !== 'none');
        const total = rows.length;
        return { total, pending: total, complete: 0, avgProgress: 35, avgAmount: 0 };
    }

    function buildSummaryHtml(row) {
        const table = row.closest('table');
        if (!table) return '';
        const summary = computeSummary(table);
        const createLink = findCreateLink(table.closest('.main-content'));
        const pendingText = `${summary.pending || 0} dossier(s) en attente de traitement.`;
        const avgAmount = summary.avgAmount || 0;
        const avgProgress = summary.avgProgress || 0;

        const safeLabel = createLink && createLink.label ? createLink.label.trim() : '';
        const createText = safeLabel ? (safeLabel.startsWith('+') ? safeLabel : ('+ ' + safeLabel)) : '';
        return `
            <div class="modal-summary-header">
                <div class="modal-summary-title">Suivi et actions</div>
                ${createLink ? `<a class="btn btn-sm btn-primary" href="${createLink.href}">${createText}</a>` : ''}
            </div>
            <div class="modal-summary-grid">
                <div><strong>Lignes:</strong> ${summary.total || 0}</div>
                <div><strong>Completes:</strong> ${summary.complete || 0}</div>
                <div><strong>En attente:</strong> ${summary.pending || 0}</div>
                <div><strong>Panier moyen:</strong> Ar ${avgAmount.toLocaleString('fr-FR')}</div>
                <div><strong>Avancement global:</strong> ${avgProgress}%</div>
            </div>
            <div class="modal-summary-note">${pendingText}</div>
            <div class="modal-summary-help">
                <div class="modal-summary-help-title">Aide a la decision</div>
                <div>Priorisez les elements au statut EN_ATTENTE.</div>
            </div>
        `;
    }

    function buildActions(row, container) {
        container.innerHTML = '';

        const viewLink = findViewLink(row);
        const editLink = findEditLink(row);
        const deleteForm = findDeleteForm(row);

        if (viewLink) {
            const openBtn = document.createElement('a');
            openBtn.href = viewLink.getAttribute('href');
            openBtn.className = 'btn btn-secondary';
            openBtn.textContent = 'Ouvrir';
            container.appendChild(openBtn);
        }

        if (editLink) {
            const editBtn = document.createElement('a');
            editBtn.href = editLink.getAttribute('href');
            editBtn.className = 'btn btn-warning';
            editBtn.textContent = 'Modifier';
            container.appendChild(editBtn);
        }

        if (deleteForm) {
            const deleteBtn = document.createElement('button');
            deleteBtn.type = 'button';
            deleteBtn.className = 'btn btn-danger';
            deleteBtn.textContent = deleteForm.label || 'Supprimer';
            deleteBtn.addEventListener('click', function() {
                deleteForm.form.submit();
            });
            container.appendChild(deleteBtn);
        }

        const closeBtn = document.createElement('button');
        closeBtn.type = 'button';
        closeBtn.className = 'btn btn-secondary';
        closeBtn.textContent = 'Fermer';
        closeBtn.addEventListener('click', closeModal);
        container.appendChild(closeBtn);
    }

    function openRowModal(row) {
        if (!row) return;
        const modal = ensureModal();
        const summary = modal.querySelector('.modal-summary');
        const details = modal.querySelector('.modal-details');
        const actions = modal.querySelector('.modal-actions');

        const items = extractRowDetails(row);
        if (summary) summary.innerHTML = buildSummaryHtml(row);
        if (details) details.innerHTML = buildDetailsHtml(items);
        buildActions(row, actions);

        modal.style.display = 'block';
        modal.classList.add('show');
        document.body.classList.add(BODY_BLUR_CLASS);
    }

    function markViewButtons(root) {
        const scope = root || document;
        const buttons = scope.querySelectorAll('table button, table a');
        buttons.forEach(btn => {
            const label = (btn.textContent || '').trim().toLowerCase();
            if (label.includes('voir') || label.includes('options') || btn.classList.contains('btn-view') || btn.classList.contains('btn-options')) {
                btn.setAttribute('data-row-view', '1');
            }
        });
    }

    function init() {
        ensureOptionsButtons(document);
        markViewButtons(document);
        let refreshPending = false;

        const observer = new MutationObserver(() => {
            if (refreshPending) return;
            refreshPending = true;
            window.requestAnimationFrame(() => {
                refreshPending = false;
                ensureOptionsButtons(document);
                markViewButtons(document);
            });
        });
        observer.observe(document.body, { childList: true, subtree: true });

        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                closeModal();
            }
        });

        document.addEventListener('click', function(event) {
            const trigger = event.target.closest('[data-row-view]');
            if (!trigger) return;
            const row = trigger.closest('tr');
            if (!row) return;
            event.preventDefault();
            event.stopPropagation();
            event.stopImmediatePropagation();
            openRowModal(row);
        }, true);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
