// Sidebar navigation and menu management
class SidebarManager {
    static toggleMenu() {
        const sidebar = document.querySelector('.sidebar');
        if (sidebar) {
            sidebar.classList.toggle('collapsed');
        }
    }

    static setActiveMenu(path) {
        const menuItems = document.querySelectorAll('.sidebar-menu a');
        menuItems.forEach(item => {
            const href = item.getAttribute('href');
            if (href === path || window.location.pathname.includes(href)) {
                item.classList.add('active');
                item.closest('li').classList.add('active');
                const submenu = item.closest('.sidebar-submenu');
                if (submenu) {
                    const parentItem = submenu.closest('.sidebar-menu-item.has-submenu');
                    if (parentItem) {
                        parentItem.classList.add('open');
                    }
                }
            } else {
                item.classList.remove('active');
                item.closest('li').classList.remove('active');
            }
        });
    }

    static expandMenu(selector) {
        const menu = document.querySelector(selector);
        if (menu) {
            menu.classList.add('expanded');
        }
    }

    static collapseMenu(selector) {
        const menu = document.querySelector(selector);
        if (menu) {
            menu.classList.remove('expanded');
        }
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    SidebarManager.setActiveMenu(window.location.pathname);

    const submenuLinks = document.querySelectorAll('.sidebar-menu-item.has-submenu > .sidebar-menu-link');
    submenuLinks.forEach(link => {
        link.addEventListener('click', function(event) {
            const href = link.getAttribute('href');
            if (!href || href === '#') {
                event.preventDefault();
                link.parentElement.classList.toggle('open');
            }
        });
    });
});

// Usage:
// SidebarManager.toggleMenu();
// SidebarManager.setActiveMenu('/erp/articles');
