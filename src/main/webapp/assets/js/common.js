/* Common JavaScript Utilities */

const APP_CONTEXT = "/erp-system";
const API_BASE_URL = `${APP_CONTEXT}/api`;

/**
 * Get JWT token from localStorage
 */
function getToken() {
    return localStorage.getItem("accessToken")
        || localStorage.getItem("access_token")
        || localStorage.getItem("jwtToken")
        || sessionStorage.getItem("accessToken")
        || sessionStorage.getItem("access_token")
        || sessionStorage.getItem("jwtToken");
}

/**
 * Set JWT token in localStorage
 */
function setToken(token) {
    localStorage.setItem("accessToken", token);
    localStorage.setItem("access_token", token);
    localStorage.setItem("jwtToken", token);
    sessionStorage.setItem("accessToken", token);
    sessionStorage.setItem("access_token", token);
    sessionStorage.setItem("jwtToken", token);
}

/**
 * Clear JWT token from localStorage
 */
function clearToken() {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("access_token");
    localStorage.removeItem("jwtToken");
    sessionStorage.removeItem("accessToken");
    sessionStorage.removeItem("access_token");
    sessionStorage.removeItem("jwtToken");
}

/**
 * Check if user is authenticated
 */
function isAuthenticated() {
    const token = getToken();
    if (!token) return false;
    
    try {
        const decoded = JSON.parse(atob(token.split('.')[1]));
        return decoded.exp * 1000 > new Date().getTime();
    } catch (e) {
        return false;
    }
}

/**
 * Get current user from token
 */
function getCurrentUser() {
    const token = getToken();
    if (!token) return null;
    
    try {
        return JSON.parse(atob(token.split('.')[1]));
    } catch (e) {
        return null;
    }
}

/**
 * AJAX wrapper with token handling
 */
function ajaxCall(url, method, data, successCallback, errorCallback) {
    const options = {
        method: method || 'GET',
        credentials: 'same-origin',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    };

    const token = getToken();
    if (token) {
        options.headers['Authorization'] = 'Bearer ' + token;
    }

    if (data && (method === 'POST' || method === 'PUT')) {
        options.body = JSON.stringify(data);
    }

    fetch(url, options)
        .then(async (response) => {
            if (response.status === 401) {
                clearToken();
                window.location.href = APP_CONTEXT + '/login';
                return null;
            }

            let payload = null;
            const contentType = (response.headers.get('content-type') || '').toLowerCase();
            if (contentType.includes('application/json')) {
                try {
                    payload = await response.json();
                } catch (e) {
                    payload = null;
                }
            } else {
                // Some endpoints may return empty body or plain text errors
                try {
                    const text = await response.text();
                    payload = text && text.trim() ? { message: text } : null;
                } catch (e) {
                    payload = null;
                }
            }

            return { status: response.status, data: payload };
        })
        .then(result => {
            if (!result) return;
            if (result.status >= 200 && result.status < 300) {
                if (successCallback) successCallback(result.data);
            } else {
                if (errorCallback) errorCallback(result.data || { message: 'Erreur serveur' });
            }
        })
        .catch(error => {
            console.error('AJAX Error:', error);
            if (errorCallback) errorCallback({ message: error.message });
        });
}

/**
 * Format currency in Ariary (Ar) with thousands separators
 */
function formatCurrency(value) {
    let number = 0;
    if (typeof value === 'number') {
        number = value;
    } else if (value !== null && value !== undefined && value !== '') {
        const parsed = parseFloat(value);
        number = isNaN(parsed) ? 0 : parsed;
    }
    return 'Ar ' + number.toLocaleString('fr-FR', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    });
}

/**
 * Format date safely
 */
function formatDate(value) {
    if (!value) return '-';
    try {
        return new Date(value).toLocaleDateString();
    } catch (e) {
        return String(value);
    }
}

/**
 * Show success notification
 */
function showSuccess(message) {
    showToast(message, 'success');
}

/**
 * Show error notification
 */
function showError(message) {
    showToast(message, 'error');
}

/**
 * Show info notification
 */
function showInfo(message) {
    showToast(message, 'info');
}

/**
 * Show toast notification
 */
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        top: 80px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 4px;
        z-index: 3000;
        animation: slideIn 0.3s ease;
    `;

    const colors = {
        'success': '#28a745',
        'error': '#dc3545',
        'info': '#007bff',
        'warning': '#ffc107'
    };

    toast.style.backgroundColor = colors[type] || colors['info'];
    toast.style.color = type === 'warning' ? '#333' : 'white';

    document.body.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

/**
 * Confirm dialog
 */
function confirm(title, message, okCallback, cancelCallback) {
    const html = `
        <div class="modal-overlay" id="confirmModal">
            <div class="modal-dialog">
                <div class="modal-header">
                    <h5>${title}</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    ${message}
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Annuler</button>
                    <button type="button" class="btn btn-primary" id="confirmOk">OK</button>
                </div>
            </div>
        </div>
    `;

    const modal = document.createElement('div');
    modal.innerHTML = html;
    document.body.appendChild(modal);

    document.getElementById('confirmOk').onclick = () => {
        if (okCallback) okCallback();
        modal.remove();
    };

    document.querySelector('[data-dismiss="modal"]').onclick = () => {
        if (cancelCallback) cancelCallback();
        modal.remove();
    };
}

/**
 * Navigate to URL
 */
function navigateTo(url) {
    window.location.href = url;
}

/**
 * Save to localStorage
 */
function saveToStorage(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
}

/**
 * Get from localStorage
 */
function getFromStorage(key) {
    const item = localStorage.getItem(key);
    return item ? JSON.parse(item) : null;
}

/**
 * Remove from localStorage
 */
function removeFromStorage(key) {
    localStorage.removeItem(key);
}

// CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(400px); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(400px); opacity: 0; }
    }
`;
document.head.appendChild(style);
