(function() {
    const CARD_SELECTORS = [
        '.kpi-card',
        '.chart-container',
        '.client-action-card',
        '.client-stat',
        '.client-hero-card',
        '.detail-container'
    ].join(',');

    function normalizeText(value) {
        return (value || '')
            .toString()
            .toLowerCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '');
    }

    function normalizeStatus(value) {
        return (value || '')
            .toString()
            .trim()
            .toUpperCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .replace(/\s+/g, '_');
    }

    function findStatusIndex(table) {
        const headers = Array.from(table.querySelectorAll('thead th'));
        for (let i = 0; i < headers.length; i++) {
            const label = normalizeText(headers[i].textContent);
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
            const badge = cell.querySelector('.badge, .badge-status, .client-pill');
            if (badge) return badge.textContent.trim();
            return cell.textContent.trim();
        }
        const badge = row.querySelector('.badge, .badge-status, .client-pill');
        if (badge) return badge.textContent.trim();
        return '';
    }

    function collectStatuses(root) {
        const statuses = new Set();
        const tables = Array.from(root.querySelectorAll('table'));
        tables.forEach(table => {
            const statusIndex = findStatusIndex(table);
            if (statusIndex < 0) return;
            const rows = table.querySelectorAll('tbody tr');
            rows.forEach(row => {
                const status = extractStatusFromRow(row, statusIndex);
                if (status) statuses.add(status);
            });
        });
        root.querySelectorAll('.badge, .badge-status, .client-pill').forEach(el => {
            const text = el.textContent.trim();
            if (text) statuses.add(text);
        });
        return statuses;
    }

    function applyLocalFilters(root, query, status) {
        const queryNorm = normalizeText(query);
        const statusNorm = normalizeStatus(status);

        root.querySelectorAll('table').forEach(table => {
            const statusIndex = findStatusIndex(table);
            table.querySelectorAll('tbody tr').forEach(row => {
                const rowText = normalizeText(row.textContent);
                const rowStatus = normalizeStatus(extractStatusFromRow(row, statusIndex));
                const queryMatch = !queryNorm || rowText.includes(queryNorm);
                const statusMatch = !statusNorm || rowStatus === statusNorm;
                row.classList.toggle('global-hidden', !(queryMatch && statusMatch));
            });
        });

        root.querySelectorAll(CARD_SELECTORS).forEach(card => {
            const cardText = normalizeText(card.textContent);
            const match = !queryNorm || cardText.includes(queryNorm);
            card.classList.toggle('global-hidden', !match);
        });
    }

    function ensureFilterBar(container, statusOptions) {
        let filterBar = container.querySelector('.filters');
        if (!filterBar) {
            filterBar = document.createElement('div');
            filterBar.className = 'filters page-filter-bar';
            const header = container.querySelector('.page-header');
            if (header && header.parentElement === container) {
                header.insertAdjacentElement('afterend', filterBar);
            } else {
                container.insertBefore(filterBar, container.firstChild);
            }
        }

        if (!filterBar.querySelector('.page-search-input')) {
            const group = document.createElement('div');
            group.className = 'filter-group';
            const label = document.createElement('label');
            label.textContent = 'Recherche';
            const input = document.createElement('input');
            input.type = 'text';
            input.placeholder = 'Rechercher...';
            input.className = 'page-search-input';
            group.appendChild(label);
            group.appendChild(input);
            filterBar.appendChild(group);
        }

        const existingStatus = filterBar.querySelector('.page-status-select');
        if (statusOptions && statusOptions.length > 0) {
            if (!existingStatus) {
                const group = document.createElement('div');
                group.className = 'filter-group';
                const label = document.createElement('label');
                label.textContent = 'Statut';
                const select = document.createElement('select');
                select.className = 'page-status-select';
                group.appendChild(label);
                group.appendChild(select);
                filterBar.appendChild(group);
            }
        }

        if (!filterBar.querySelector('.filter-actions')) {
            const actions = document.createElement('div');
            actions.className = 'filter-actions';
            filterBar.appendChild(actions);
        }

        if (!filterBar.querySelector('.page-filter-reset')) {
            const actions = filterBar.querySelector('.filter-actions');
            const reset = document.createElement('button');
            reset.type = 'button';
            reset.className = 'btn btn-secondary page-filter-reset';
            reset.textContent = 'Effacer';
            actions.appendChild(reset);
        }

        return filterBar;
    }

    function refreshStatusSelect(filterBar, statuses) {
        const select = filterBar.querySelector('.page-status-select');
        if (!select) return;
        const current = select.value;
        select.innerHTML = '';
        const optionAll = document.createElement('option');
        optionAll.value = '';
        optionAll.textContent = 'Tous';
        select.appendChild(optionAll);
        statuses.forEach(status => {
            const opt = document.createElement('option');
            opt.value = status;
            opt.textContent = status;
            select.appendChild(opt);
        });
        select.value = current;
    }

    function initContainer(container) {
        const statuses = Array.from(collectStatuses(container));
        const filterBar = ensureFilterBar(container, statuses);
        refreshStatusSelect(filterBar, statuses);

        const searchInput = filterBar.querySelector('.page-search-input');
        const statusSelect = filterBar.querySelector('.page-status-select');
        const resetBtn = filterBar.querySelector('.page-filter-reset');

        const apply = () => {
            const query = searchInput ? searchInput.value : '';
            const status = statusSelect ? statusSelect.value : '';
            applyLocalFilters(container, query, status);
        };

        if (searchInput && !searchInput.dataset.bound) {
            searchInput.dataset.bound = '1';
            searchInput.addEventListener('input', apply);
        }
        if (statusSelect && !statusSelect.dataset.bound) {
            statusSelect.dataset.bound = '1';
            statusSelect.addEventListener('change', apply);
        }
        if (resetBtn && !resetBtn.dataset.bound) {
            resetBtn.dataset.bound = '1';
            resetBtn.addEventListener('click', () => {
                if (searchInput) searchInput.value = '';
                if (statusSelect) statusSelect.value = '';
                apply();
            });
        }

        let refreshPending = false;
        const scheduleRefresh = () => {
            if (refreshPending) return;
            refreshPending = true;
            window.requestAnimationFrame(() => {
                refreshPending = false;
                const nextStatuses = Array.from(collectStatuses(container));
                refreshStatusSelect(filterBar, nextStatuses);
            });
        };
        const observer = new MutationObserver(scheduleRefresh);
        observer.observe(container, { childList: true, subtree: true });
    }

    function init() {
        const containers = [];
        document.querySelectorAll('.main-content .container').forEach(el => containers.push(el));
        document.querySelectorAll('.client-shell').forEach(el => containers.push(el));
        if (!containers.length) return;
        containers.forEach(initContainer);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
