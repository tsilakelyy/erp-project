<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ERP System - Login</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <style>
        body {
            min-height: 100vh;
        }
        .login-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            max-width: 440px;
            width: min(440px, 92vw);
            padding: 40px;
            min-height: 420px;
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header h1 {
            font-size: 28px;
            color: #333;
            margin-bottom: 10px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-control {
            padding: 12px;
            border-radius: 5px;
            border: 1px solid #ddd;
        }
        .btn-login {
            width: 100%;
            padding: 12px;
            background: var(--brand-gradient);
            border: none;
            color: white;
            font-weight: bold;
            border-radius: 5px;
            cursor: pointer;
            transition: opacity 0.3s;
        }
        .btn-login:hover {
            opacity: 0.9;
        }
        .btn-login:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            display: none;
        }
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            display: none;
        }
        .loading {
            display: none;
            text-align: center;
            margin-top: 10px;
        }
        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body class="auth-page">
    <div class="auth-content">
    <div class="login-flip-scene">
    <div class="login-container login-flip-card">
        <div class="login-header">
            <h1>ERP System</h1>
            <p class="text-muted">Plateforme de gestion integree</p>
        </div>

        <div id="errorMessage" class="error-message"></div>
        <div id="successMessage" class="success-message"></div>

        <form id="loginForm" onsubmit="handleLogin(event)">
            <div class="form-group">
                <label for="username" class="form-label">Username</label>
                <input type="text" id="username" name="username" class="form-control" required autofocus>
            </div>

            <div class="form-group">
                <label for="password" class="form-label">Password</label>
                <input type="password" id="password" name="password" class="form-control" required>
            </div>

            <button type="submit" id="loginBtn" class="btn-login">Login</button>
            
            <div class="loading" id="loading">
                <div class="spinner"></div>
                <p>Connexion en cours...</p>
            </div>
        </form>

        <div style="margin-top: 20px; text-align: center; color: #666; font-size: 12px;">
            <p>Utilisateurs de test : admin / password123</p>
            <p style="margin-top: 15px;">
                <a href="<c:url value='/debug'/>" style="color: #667eea; text-decoration: none;">
                    Probleme d'authentification ? Accedez a la page de debug
                </a>
            </p>
            <p style="margin-top: 12px;">
                <a href="<c:url value='/client/login'/>" class="flip-link" data-flip-target="<c:url value='/client/login'/>">
                    Acces espace client
                </a>
            </p>
        </div>
    </div>
    </div>

    <script>
        const LOGIN_API_URL = '<c:url value="/api/auth/login"/>';
        const DASHBOARD_URL = '<c:url value="/dashboard"/>';
        const CLIENT_PORTAL_URL = '<c:url value="/client"/>';
        const DEBUG_URL = '<c:url value="/debug"/>';

        // Au chargement : supprimer tout token/cookie cote client pour eviter les redirections automatiques
        window.addEventListener('load', function() {
            try {
                // Supprimer les tokens en stockage
                sessionStorage.removeItem('jwtToken');
                sessionStorage.removeItem('username');
                sessionStorage.removeItem('roles');
                localStorage.removeItem('jwtToken');
                localStorage.removeItem('username');
                localStorage.removeItem('roles');
                localStorage.removeItem('accessToken');
                localStorage.removeItem('access_token');
                sessionStorage.removeItem('accessToken');
                sessionStorage.removeItem('access_token');

                // Supprimer cookies usuels d'authent (ne peut supprimer cookies HttpOnly)
                function deleteCookie(name) {
                    document.cookie = name + '=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Lax';
                }
                deleteCookie('jwtToken');
                deleteCookie('JSESSIONID');
                deleteCookie('Authorization');
            } catch (e) {
                console.debug('Clear storage error:', e);
            }

            // IMPORTANT : Ne pas valider ni rediriger automatiquement ici.
            // La redirection ne doit se produire que apres une authentification reussie (POST).
        });

        async function handleLogin(event) {
            event.preventDefault();
            
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            const loginBtn = document.getElementById('loginBtn');
            const loading = document.getElementById('loading');
            const errorMessage = document.getElementById('errorMessage');
            const successMessage = document.getElementById('successMessage');

            // Masquer les messages
            errorMessage.style.display = 'none';
            successMessage.style.display = 'none';

            // Afficher le loading
            loginBtn.disabled = true;
            loading.style.display = 'block';

            try {
                // Appel API de login (adapte le chemin si necessaire)
                const response = await fetch(LOGIN_API_URL, {
                    method: 'POST',
                    credentials: 'same-origin',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        username: username,
                        password: password
                    })
                });

                // Essayer d'analyser la reponse JSON, proteger si le body est vide
                let data = {};
                try {
                    data = await response.json();
                } catch (e) {
                    // nothing
                }

                if (response.ok && data.token) {
                    // Succes - stockage du token et des infos utilisateur
                    sessionStorage.setItem('jwtToken', data.token);
                    sessionStorage.setItem('username', data.user);
                    sessionStorage.setItem('roles', JSON.stringify(data.roles));
                    localStorage.setItem('accessToken', data.token);
                    localStorage.setItem('access_token', data.token);
                    localStorage.setItem('jwtToken', data.token);

                    // Afficher message de succes
                    successMessage.textContent = 'Connexion reussie. Redirection...';
                    successMessage.style.display = 'block';

                    const roles = Array.isArray(data.roles) ? data.roles : [];
                    const isClient = roles.includes('CLIENT');
                    const target = isClient ? CLIENT_PORTAL_URL : DASHBOARD_URL;
                    window.location.href = target;
                    return;

                } else {
                    // Erreur - Afficher le message
                    const errMsg = (data && data.error) ? data.error : 'Erreur de connexion';
                    throw new Error(errMsg);
                }

            } catch (error) {
                console.error('Erreur de login:', error);
                const errorMsg = error.message || 'Erreur de connexion. Verifiez vos identifiants.';
                errorMessage.textContent = 'Erreur : ' + errorMsg;
                errorMessage.innerHTML += '<br/><a href="' + DEBUG_URL + '" style="color: #dc3545; font-size: 12px; text-decoration: underline;">Accedez a la page debug pour plus d\'informations</a>';
                errorMessage.style.display = 'block';
                
                // Reactiver le bouton
                loginBtn.disabled = false;
                loading.style.display = 'none';
            }
        }

        // Gestion de l'erreur dans l'URL (si redirection depuis serveur)
        const urlParams = new URLSearchParams(window.location.search);
        const error = urlParams.get('error');
        if (error) {
            document.getElementById('errorMessage').textContent = 'Erreur : ' + decodeURIComponent(error);
            document.getElementById('errorMessage').style.display = 'block';
        }
    </script>

    <script src="<c:url value='/assets/js/login-flip.js'/>"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </div>
</body>
</html>



