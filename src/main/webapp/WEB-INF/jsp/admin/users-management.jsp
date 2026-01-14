<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Users Management - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/css/style-tables.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Users Management</h1>
                <button class="btn btn-primary" onclick="openUserForm()">+ New User</button>
            </div>

            <div class="search-bar">
                <input type="text" id="searchInput" placeholder="Search users..." onkeyup="filterTable('usersTable', this.value)">
            </div>

            <table class="table" id="usersTable">
                <thead>
                    <tr>
                        <th>
                            <input type="checkbox" onchange="toggleAll(this)">
                        </th>
                        <th>Username</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Roles</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="usersList">
                    <!-- Populated by JavaScript -->
                </tbody>
            </table>
        </div>

        <!-- User Form Modal -->
        <div id="userModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>User Form</h3>
                    <button class="modal-close" onclick="closeUserForm()">&times;</button>
                </div>
                <div class="modal-body">
                    <form id="userForm" onsubmit="submitUserForm(event)">
                        <input type="hidden" id="userId">
                        
                        <div class="form-group">
                            <label>Username</label>
                            <input type="text" name="username" class="form-control" data-validate required>
                        </div>

                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" name="email" class="form-control" data-validate required>
                        </div>

                        <div class="form-group">
                            <label>Full Name</label>
                            <input type="text" name="fullName" class="form-control" data-validate>
                        </div>

                        <div class="form-group">
                            <label>Password</label>
                            <input type="password" name="password" id="password" class="form-control">
                            <small>Leave blank to keep existing password</small>
                        </div>

                        <div class="form-group">
                            <label>Roles</label>
                            <select name="roles" class="form-control" multiple size="4">
                                <option value="ACHETEUR">ACHETEUR (Buyer)</option>
                                <option value="MAGASINIER">MAGASINIER (Warehouse)</option>
                                <option value="COMMERCIAL">COMMERCIAL (Sales)</option>
                                <option value="FINANCE">FINANCE</option>
                                <option value="DAF">DAF (CFO)</option>
                                <option value="DIRECTION">DIRECTION (Director)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Active</label>
                            <input type="checkbox" name="actif" checked>
                        </div>

                        <button type="submit" class="btn btn-primary">Save</button>
                        <button type="button" class="btn btn-secondary" onclick="closeUserForm()">Cancel</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script src="<c:url value='/assets/js/forms.js'/>"></script>
    <script src="<c:url value='/assets/js/tables.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadUsers();
        });

        function loadUsers() {
            ajaxCall('/erp/api/users', 'GET', null,
                function(response) {
                    const users = response.data || response;
                    displayUsers(users);
                },
                function(error) { showError('Failed to load users'); }
            );
        }

        function displayUsers(users) {
            const tbody = document.getElementById('usersList');
            tbody.innerHTML = '';

            if (!users || users.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7">No users found</td></tr>';
                return;
            }

            users.forEach(user => {
                const tr = document.createElement('tr');
                const roles = Array.isArray(user.roles) ? user.roles.map(r => r.libelle || r).join(', ') : user.roles;
                const status = user.actif ? '<span class="badge badge-success">Active</span>' : '<span class="badge badge-danger">Inactive</span>';

                tr.innerHTML = `
                    <td><input type="checkbox" value="${user.id}"></td>
                    <td>${user.username}</td>
                    <td>${user.fullName || '-'}</td>
                    <td>${user.email}</td>
                    <td>${roles}</td>
                    <td>${status}</td>
                    <td>
                        <button class="btn btn-sm btn-info" onclick="editUser(${user.id})">Edit</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteUser(${user.id})">Delete</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function openUserForm() {
            document.getElementById('userId').value = '';
            document.getElementById('userForm').reset();
            document.getElementById('userModal').style.display = 'block';
        }

        function closeUserForm() {
            document.getElementById('userModal').style.display = 'none';
        }

        function editUser(id) {
            ajaxCall('/erp/api/users/' + id, 'GET', null,
                function(response) {
                    const user = response.data || response;
                    document.getElementById('userId').value = user.id;
                    document.querySelector('[name="username"]').value = user.username;
                    document.querySelector('[name="email"]').value = user.email;
                    document.querySelector('[name="fullName"]').value = user.fullName || '';
                    document.querySelector('[name="actif"]').checked = user.actif;
                    
                    const roleSelect = document.querySelector('[name="roles"]');
                    Array.from(roleSelect.options).forEach(opt => {
                        opt.selected = user.roles && user.roles.some(r => r.libelle === opt.value);
                    });

                    openUserForm();
                },
                function(error) { showError('Failed to load user'); }
            );
        }

        function submitUserForm(e) {
            e.preventDefault();
            const form = document.getElementById('userForm');
            
            if (!validateForm(form)) {
                showError('Please fill required fields');
                return;
            }

            const userId = document.getElementById('userId').value;
            const data = {
                username: form.querySelector('[name="username"]').value,
                email: form.querySelector('[name="email"]').value,
                fullName: form.querySelector('[name="fullName"]').value,
                password: form.querySelector('[name="password"]').value,
                actif: form.querySelector('[name="actif"]').checked
            };

            const method = userId ? 'PUT' : 'POST';
            const url = userId ? '/erp/api/users/' + userId : '/erp/api/users';

            ajaxCall(url, method, data,
                function(response) {
                    showSuccess('User saved successfully');
                    closeUserForm();
                    loadUsers();
                },
                function(error) { showError('Failed to save user: ' + (error.message || '')); }
            );
        }

        function deleteUser(id) {
            if (!confirm('Are you sure?')) return;
            
            ajaxCall('/erp/api/users/' + id, 'DELETE', null,
                function(response) {
                    showSuccess('User deleted');
                    loadUsers();
                },
                function(error) { showError('Failed to delete user'); }
            );
        }

        function filterTable(tableId, query) {
            const rows = document.querySelectorAll('#' + tableId + ' tbody tr');
            rows.forEach(row => {
                const match = row.textContent.toLowerCase().includes(query.toLowerCase());
                row.style.display = match ? '' : 'none';
            });
        }

        function toggleAll(checkbox) {
            const checkboxes = document.querySelectorAll('#usersList input[type="checkbox"]');
            checkboxes.forEach(cb => cb.checked = checkbox.checked);
        }
    </script>
</body>
</html>
