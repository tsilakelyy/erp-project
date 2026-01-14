// Table utilities for sorting, filtering, and pagination
class TableManager {
    constructor(tableId) {
        this.table = document.getElementById(tableId);
        this.currentSort = { column: 0, asc: true };
    }

    enableSorting() {
        if (!this.table) return;
        const headers = this.table.querySelectorAll('thead th');
        headers.forEach((header, index) => {
            header.style.cursor = 'pointer';
            header.addEventListener('click', () => this.sortByColumn(index));
        });
    }

    sortByColumn(columnIndex) {
        if (this.currentSort.column === columnIndex) {
            this.currentSort.asc = !this.currentSort.asc;
        } else {
            this.currentSort.column = columnIndex;
            this.currentSort.asc = true;
        }
        this.performSort();
    }

    performSort() {
        const tbody = this.table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));

        rows.sort((a, b) => {
            const aValue = a.cells[this.currentSort.column].textContent;
            const bValue = b.cells[this.currentSort.column].textContent;
            
            const comparison = aValue.localeCompare(bValue, undefined, { numeric: true });
            return this.currentSort.asc ? comparison : -comparison;
        });

        rows.forEach(row => tbody.appendChild(row));
    }

    filterRows(searchText, columnIndex = null) {
        const rows = this.table.querySelectorAll('tbody tr');
        rows.forEach(row => {
            let match = false;
            if (columnIndex !== null) {
                match = row.cells[columnIndex].textContent.includes(searchText);
            } else {
                match = Array.from(row.cells).some(cell => 
                    cell.textContent.includes(searchText)
                );
            }
            row.style.display = match ? '' : 'none';
        });
    }

    enableCheckboxes() {
        const headerCheckbox = this.table.querySelector('thead input[type="checkbox"]');
        const rowCheckboxes = this.table.querySelectorAll('tbody input[type="checkbox"]');

        if (headerCheckbox) {
            headerCheckbox.addEventListener('change', (e) => {
                rowCheckboxes.forEach(cb => cb.checked = e.target.checked);
            });
        }

        rowCheckboxes.forEach(cb => {
            cb.addEventListener('change', () => {
                const allChecked = Array.from(rowCheckboxes).every(c => c.checked);
                if (headerCheckbox) headerCheckbox.checked = allChecked;
            });
        });
    }

    getSelectedRows() {
        const checkboxes = this.table.querySelectorAll('tbody input[type="checkbox"]:checked');
        return Array.from(checkboxes).map(cb => cb.closest('tr'));
    }
}

// Usage:
// const tableManager = new TableManager('articles-table');
// tableManager.enableSorting();
// tableManager.enableCheckboxes();
