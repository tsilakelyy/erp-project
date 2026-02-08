(function() {
    function clamp(value) {
        const num = Number(value);
        if (Number.isNaN(num)) return 0;
        return Math.max(0, Math.min(100, num));
    }

    function createBar(item) {
        const wrapper = document.createElement('div');
        wrapper.className = `report-bar ${item.tone ? 'tone-' + item.tone : ''}`;

        const track = document.createElement('div');
        track.className = 'report-bar-track';

        const fill = document.createElement('div');
        fill.className = 'report-bar-fill';
        const value = clamp(item.value);
        fill.style.height = `${value}%`;
        fill.textContent = `${value}%`;

        track.appendChild(fill);
        wrapper.appendChild(track);

        const label = document.createElement('div');
        label.className = 'report-bar-label';
        label.textContent = item.label || '-';
        wrapper.appendChild(label);

        if (item.note) {
            const note = document.createElement('div');
            note.className = 'report-bar-note';
            note.textContent = item.note;
            wrapper.appendChild(note);
        }

        return wrapper;
    }

    function render(container, items) {
        if (!container) return;
        container.innerHTML = '';
        if (!items || items.length === 0) {
            container.innerHTML = '<div class="report-bar-empty">Aucune donnee</div>';
            return;
        }
        items.forEach(item => {
            container.appendChild(createBar(item));
        });
    }

    window.ReportBars = { render };
})();
