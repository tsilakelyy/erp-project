/* Common JavaScript Utilities */

const API_BASE_URL = "/erp/api";

/**
 * Get JWT token from localStorage
 */
function getToken() {
    return localStorage.getItem("access_token");
}

/**
 * Set JWT token in localStorage
 */
function setToken(token) {
    localStorage.setItem("access_token", token);
}

/**
 * Clear JWT token from localStorage
 */
function clearToken() {
    localStorage.removeItem("access_token");
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
        .then(response => {
            if (response.status === 401) {
                clearToken();
                window.location.href = '/erp/login';
                return;
            }
            return response.json().then(data => ({ status: response.status, data: data }));
        })
        .then(result => {
            if (result.status >= 200 && result.status < 300) {
                if (successCallback) successCallback(result.data);
            } else {
                if (errorCallback) errorCallback(result.data);
            }
        })
        .catch(error => {
            console.error('AJAX Error:', error);
            if (errorCallback) errorCallback({ message: error.message });
        });
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
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
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
