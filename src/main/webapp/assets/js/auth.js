// Authentication utilities - token management and login handling
class Auth {
    static login(username, password, onSuccess, onError) {
        const data = { username, password };
        fetch('/erp/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        })
        .then(r => r.json())
        .then(response => {
            if (response.data || response.accessToken) {
                const token = response.data?.accessToken || response.accessToken;
                const refreshToken = response.data?.refreshToken || response.refreshToken;
                localStorage.setItem('accessToken', token);
                localStorage.setItem('refreshToken', refreshToken);
                localStorage.setItem('user', JSON.stringify(response.data?.user || response.user));
                if (onSuccess) onSuccess(response);
            } else {
                if (onError) onError({ message: response.message || 'Login failed' });
            }
        })
        .catch(err => {
            if (onError) onError(err);
        });
    }

    static logout() {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        localStorage.removeItem('user');
        window.location.href = '/erp/login';
    }

    static refreshAccessToken(onSuccess, onError) {
        const refreshToken = localStorage.getItem('refreshToken');
        if (!refreshToken) {
            this.logout();
            return;
        }

        const data = { refreshToken };
        fetch('/erp/api/auth/refresh', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        })
        .then(r => r.json())
        .then(response => {
            if (response.data?.accessToken || response.accessToken) {
                const token = response.data?.accessToken || response.accessToken;
                localStorage.setItem('accessToken', token);
                if (onSuccess) onSuccess(token);
            } else {
                this.logout();
            }
        })
        .catch(err => {
            this.logout();
            if (onError) onError(err);
        });
    }

    static isAuthenticated() {
        return !!localStorage.getItem('accessToken');
    }

    static getCurrentUser() {
        const user = localStorage.getItem('user');
        return user ? JSON.parse(user) : null;
    }

    static hasRole(role) {
        const user = this.getCurrentUser();
        if (!user || !user.roles) return false;
        return user.roles.some(r => r.libelle === role);
    }

    static hasPermission(permission) {
        const user = this.getCurrentUser();
        if (!user || !user.permissions) return false;
        return user.permissions.some(p => p.libelle === permission);
    }
}

// Usage:
// Auth.login('admin', 'admin123', 
//     (response) => { showSuccess('Logged in'); window.location.href = '/erp/dashboard'; },
//     (error) => { showError('Login failed: ' + error.message); }
// );
// Auth.logout();
// Auth.hasRole('DIRECTION');
