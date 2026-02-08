<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ERP Debug & Direction - Authentification</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f8f9fa;
            padding: 20px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .debug-container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }
        
        .section {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
        }
        
        .section-title {
            color: #667eea;
            font-weight: bold;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        
        .user-row {
            padding: 15px;
            border-left: 4px solid #667eea;
            background-color: #f8f9fa;
            margin-bottom: 10px;
            border-radius: 4px;
        }
        
        .hash-display {
            background-color: #272822;
            color: #f8f8f2;
            padding: 15px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            word-break: break-all;
            overflow-x: auto;
        }
        
        .success-msg {
            background-color: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 15px;
            border-left: 4px solid #28a745;
        }
        
        .error-msg {
            background-color: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 15px;
            border-left: 4px solid #dc3545;
        }
        
        .info-msg {
            background-color: #d1ecf1;
            color: #0c5460;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 15px;
            border-left: 4px solid #17a2b8;
        }
        
        .form-section {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 15px;
        }
        
        .btn-custom {
            padding: 8px 20px;
            font-weight: bold;
        }
        
        .role-badge {
            display: inline-block;
            background-color: #667eea;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            margin-right: 5px;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 14px;
        }
        
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-inactive {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .nav-buttons {
            margin-bottom: 20px;
        }
        
        .nav-buttons a, .nav-buttons button {
            margin-right: 10px;
        }
    </style>
    <jsp:include page="/WEB-INF/jsp/layout/styles.jsp"/>
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <div class="main-content">
    <div class="debug-container">
        
        <!-- Header -->
        <div class="header">
            <h1>🔧 ERP System - Debug & Direction</h1>
            <p>Vérification et gestion de l'authentification BCrypt</p>
        </div>
        
        <!-- Navigation -->
        <div class="nav-buttons">
            <a href="/" class="btn btn-secondary">← Retour à la page d'accueil</a>
            <a href="/login" class="btn btn-primary">🔐 Retour à la connexion</a>
        </div>
        
        <!-- Messages d'erreur/succès -->
        <c:if test="${not empty error}">
            <div class="error-msg">
                ❌ <strong>Erreur:</strong> ${error}
            </div>
        </c:if>
        
        <c:if test="${not empty verifyResult}">
            <div class="section">
                <div class="section-title">📋 Résultat de la Vérification</div>
                <c:choose>
                    <c:when test="${verifyResult.matches}">
                        <div class="success-msg">
                            ✅ ${verifyResult.status}
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="error-msg">
                            ❌ ${verifyResult.status}
                        </div>
                    </c:otherwise>
                </c:choose>
                <table class="table table-sm">
                    <tr>
                        <td><strong>Utilisateur:</strong></td>
                        <td>${verifyResult.username}</td>
                    </tr>
                    <tr>
                        <td><strong>Mot de passe testé:</strong></td>
                        <td><code>${verifyResult.testPassword}</code></td>
                    </tr>
                    <tr>
                        <td><strong>Hash BCrypt (BD):</strong></td>
                        <td><div class="hash-display">${verifyResult.storedHash}</div></td>
                    </tr>
                    <tr>
                        <td><strong>Longueur du hash:</strong></td>
                        <td>${verifyResult.hashLength} caractères (attendu: 60)</td>
                    </tr>
                </table>
            </div>
        </c:if>
        
        <c:if test="${not empty resetMessage}">
            <div class="success-msg">
                ${resetMessage}
            </div>
        </c:if>
        
        <c:if test="${not empty generatedHash}">
            <div class="section">
                <div class="section-title">🔐 Hash BCrypt Généré</div>
                <div class="info-msg">
                    ✓ Hash généré pour le mot de passe: <code>${generatedPassword}</code>
                </div>
                <div class="hash-display">${generatedHash}</div>
                <p style="margin-top: 10px; font-size: 12px; color: #666;">
                    Vous pouvez copier ce hash et l'utiliser dans votre base de données.
                </p>
            </div>
        </c:if>
        
        <c:if test="${not empty bcryptTest}">
            <div class="section">
                <div class="section-title">🧪 Test BCrypt Manual</div>
                <c:choose>
                    <c:when test="${bcryptTest.matches}">
                        <div class="success-msg">
                            ✅ ${bcryptTest.status} - Le mot de passe correspond au hash
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="error-msg">
                            ❌ ${bcryptTest.status} - Le mot de passe NE correspond PAS au hash
                        </div>
                    </c:otherwise>
                </c:choose>
                <table class="table table-sm">
                    <tr>
                        <td><strong>Hash:</strong></td>
                        <td><div class="hash-display">${bcryptTest.hash}</div></td>
                    </tr>
                    <tr>
                        <td><strong>Mot de passe:</strong></td>
                        <td><code>${bcryptTest.password}</code></td>
                    </tr>
                </table>
            </div>
        </c:if>
        
        <!-- Section 1: Liste des Utilisateurs -->
        <div class="section">
            <div class="section-title">👥 Utilisateurs Configurés dans la Base de Données</div>
            <p style="color: #666; margin-bottom: 15px;">
                Total: <strong>${debugInfo.totalUsers}</strong> utilisateurs
            </p>
            
            <c:forEach items="${debugInfo}" var="user">
                <div class="user-row">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <strong style="font-size: 16px;">${user.login}</strong>
                            <div style="color: #666; font-size: 14px;">Email: ${user.email}</div>
                            <div style="margin-top: 5px;">
                                <c:forEach items="${user.roleNames}" var="roleCode">
                                    <span class="role-badge">${roleCode}</span>
                                </c:forEach>
                            </div>
                        </div>
                        <div style="text-align: right;">
                            <c:choose>
                                <c:when test="${user.active}">
                                    <span class="status-badge status-active">✓ Actif</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge status-inactive">✗ Inactif</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div style="margin-top: 10px; padding-top: 10px; border-top: 1px solid #ddd;">
                        <small style="color: #999;">
                            Hash BCrypt: <code style="color: #333;">${user.passwordHash}</code>
                            <br/>Longueur: ${user.passwordLength} caractères
                        </small>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <!-- Section 2: Vérifier un Mot de Passe -->
        <div class="section">
            <div class="section-title">✔️ Vérifier un Mot de Passe BCrypt</div>
            <form method="POST" action="/debug/verify-password" class="form-section">
                <div class="form-group mb-3">
                    <label for="username" class="form-label">Utilisateur</label>
                    <input type="text" class="form-control" id="username" name="username" 
                           value="${testUsername}" placeholder="Ex: admin" required>
                </div>
                <div class="form-group mb-3">
                    <label for="password" class="form-label">Mot de passe à tester</label>
                    <input type="password" class="form-control" id="password" name="password" 
                           placeholder="Ex: password123" required>
                </div>
                <button type="submit" class="btn btn-primary btn-custom">
                    🔍 Vérifier le mot de passe
                </button>
            </form>
        </div>
        
        <!-- Section 3: Générer un Hash BCrypt -->
        <div class="section">
            <div class="section-title">🔐 Générer un Hash BCrypt</div>
            <form method="POST" action="/debug/generate-hash" class="form-section">
                <div class="form-group mb-3">
                    <label for="genPassword" class="form-label">Mot de passe à hasher</label>
                    <input type="password" class="form-control" id="genPassword" name="password" 
                           placeholder="Entrez un mot de passe" required>
                </div>
                <button type="submit" class="btn btn-info btn-custom">
                    🔐 Générer le hash
                </button>
            </form>
            <p style="margin-top: 10px; color: #666; font-size: 14px;">
                💡 Utile pour créer manuellement des hashes pour votre base de données.
            </p>
        </div>
        
        <!-- Section 4: Test BCrypt Manual -->
        <div class="section">
            <div class="section-title">🧪 Test BCrypt - Vérification Manuel</div>
            <form method="POST" action="/debug/test-bcrypt" class="form-section">
                <div class="form-group mb-3">
                    <label for="testHash" class="form-label">Hash BCrypt</label>
                    <textarea class="form-control" id="testHash" name="testHash" rows="3" 
                              placeholder="Collez un hash BCrypt complet (ex: $2a$10$...)" required></textarea>
                </div>
                <div class="form-group mb-3">
                    <label for="testPassword2" class="form-label">Mot de passe à tester</label>
                    <input type="password" class="form-control" id="testPassword2" name="testPassword" 
                           placeholder="Entrez le mot de passe à tester" required>
                </div>
                <button type="submit" class="btn btn-warning btn-custom">
                    🧪 Tester BCrypt
                </button>
            </form>
        </div>
        
        <!-- Section 5: Réinitialiser un Mot de Passe -->
        <div class="section">
            <div class="section-title">🔄 Réinitialiser un Mot de Passe</div>
            <form method="POST" action="/debug/reset-password" class="form-section">
                <div class="alert alert-warning" role="alert">
                    ⚠️ Cette action modifiera le mot de passe dans la base de données.
                </div>
                <div class="form-group mb-3">
                    <label for="resetUsername" class="form-label">Utilisateur</label>
                    <input type="text" class="form-control" id="resetUsername" name="username" 
                           placeholder="Ex: admin" required>
                </div>
                <div class="form-group mb-3">
                    <label for="newPassword" class="form-label">Nouveau mot de passe</label>
                    <input type="password" class="form-control" id="newPassword" name="newPassword" 
                           placeholder="Entrez le nouveau mot de passe" required>
                </div>
                <button type="submit" class="btn btn-danger btn-custom">
                    🔄 Réinitialiser
                </button>
            </form>
        </div>
        
        <!-- Section 6: Informations de Débogage -->
        <div class="section">
            <div class="section-title">ℹ️ Informations de Débogage</div>
            <div class="info-msg">
                <strong>Configuration BCrypt:</strong>
                <ul style="margin-bottom: 0; margin-top: 10px;">
                    <li>Algorithm: BCryptPasswordEncoder (Spring Security)</li>
                    <li>Version: $2a$ (standard)</li>
                    <li>Longueur attendue du hash: 60 caractères</li>
                    <li>Format: $2a$10$[16 char salt][31 char hash]</li>
                </ul>
            </div>
            
            <div class="info-msg" style="margin-top: 15px;">
                <strong>Mots de passe de test par défaut:</strong>
                <ul style="margin-bottom: 0; margin-top: 10px;">
                    <li><code>admin / password123</code> (Administrateur)</li>
                    <li><code>acheteur1 / password123</code> (Acheteur)</li>
                    <li><code>commercial1 / password123</code> (Commercial)</li>
                    <li><code>magasinier1 / password123</code> (Magasinier)</li>
                    <li><code>direction1 / password123</code> (Direction)</li>
                    <li><code>finance1 / password123</code> (Finance)</li>
                </ul>
            </div>
        </div>
        
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </div>
</body>
</html>



