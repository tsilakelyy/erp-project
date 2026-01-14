<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Roles Management - ERP</title>
    <link rel="stylesheet" href="<c:url value='/assets/css/style-main.css'/>">
    <link rel="stylesheet" href="<c:url value='/assets/css/style-tables.css'/>">
</head>
<body>
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp"/>
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>Roles Management</h1>
                <button class="btn btn-primary" onclick="openRoleForm()">+ New Role</button>
            </div>

            <table class="table" id="rolesTable">
                <thead>
                    <tr>
                        <th>Role Code</th>
                        <th>Description</th>
                        <th>Active</th>
                        <th>Permissions Count</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="rolesList">
                    <!-- Populated by JavaScript -->
                </tbody>
            </table>
        </div>

        <!-- Role Form Modal -->
        <div id="roleModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Role Form</h3>
                    <button class="modal-close" onclick="closeRoleForm()">&times;</button>
                </div>
                <div class="modal-body">
                    <form id="roleForm" onsubmit="submitRoleForm(event)">
                        <input type="hidden" id="roleId">
                        
                        <div class="form-group">
                            <label>Role Code</label>
                            <input type="text" name="libelle" class="form-control" data-validate required>
                        </div>

                        <div class="form-group">
                            <label>Description</label>
                            <textarea name="description" class="form-control" rows="4"></textarea>
                        </div>

                        <div class="form-group">
                            <label>Active</label>
                            <input type="checkbox" name="actif" checked>
                        </div>

                        <h4>Assign Permissions</h4>
                        <div id="permissionsList" class="permissions-list">
                            <!-- Populated by JavaScript -->
                        </div>

                        <button type="submit" class="btn btn-primary">Save</button>
                        <button type="button" class="btn btn-secondary" onclick="closeRoleForm()">Cancel</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/jsp/layout/footer.jsp"/>

    <script src="<c:url value='/assets/js/common.js'/>"></script>
    <script src="<c:url value='/assets/js/forms.js'/>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            loadRoles();
            loadPermissions();
        });

        function loadRoles() {
            ajaxCall('/erp/api/roles', 'GET', null,
                function(response) {
                    const roles = response.data || response;
                    displayRoles(roles);
                },
                function(error) { showError('Failed to load roles'); }
            );
        }

        function loadPermissions() {
            ajaxCall('/erp/api/permissions', 'GET', null,
                function(response) {
                    const permissions = response.data || response;
                    displayPermissions(permissions);
                },
                function(error) { console.error('Failed to load permissions'); }
            );
        }

        function displayRoles(roles) {
            const tbody = document.getElementById('rolesList');
            tbody.innerHTML = '';

            if (!roles || roles.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5">No roles found</td></tr>';
                return;
            }

            roles.forEach(role => {
                const tr = document.createElement('tr');
                const status = role.actif ? '<span class="badge badge-success">Active</span>' : '<span class="badge badge-danger">Inactive</span>';
                const permCount = role.permissions ? role.permissions.length : 0;

                tr.innerHTML = `
                    <td>${role.libelle}</td>
                    <td>${role.description || '-'}</td>
                    <td>${status}</td>
                    <td>${permCount}</td>
                    <td>
                        <button class="btn btn-sm btn-info" onclick="editRole(${role.id})">Edit</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteRole(${role.id})">Delete</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function displayPermissions(permissions) {
            const container = document.getElementById('permissionsList');
            container.innerHTML = '';

            if (!permissions || permissions.length === 0) {
                container.innerHTML = '<p>No permissions available</p>';
                return;
            }

            permissions.forEach(perm => {
                const div = document.createElement('div');
                div.className = 'permission-item';
                div.innerHTML = `
                    <input type="checkbox" name="permissions" value="${perm.id}" data-perm="${perm.libelle}">
                    <label>${perm.libelle} - ${perm.description || ''}</label>
                `;
                container.appendChild(div);
            });
        }

        function openRoleForm() {
            document.getElementById('roleId').value = '';
            document.getElementById('roleForm').reset();
            document.getElementById('roleModal').style.display = 'block';
        }

        function closeRoleForm() {
            document.getElementById('roleModal').style.display = 'none';
        }

        function editRole(id) {
            ajaxCall('/erp/api/roles/' + id, 'GET', null,
                function(response) {
                    const role = response.data || response;
                    document.getElementById('roleId').value = role.id;
                    document.querySelector('[name="libelle"]').value = role.libelle;
                    document.querySelector('[name="description"]').value = role.description || '';
                    document.querySelector('[name="actif"]').checked = role.actif;
                    
                    // Check assigned permissions
                    const permCheckboxes = document.querySelectorAll('[name="permissions"]');
                    const assignedIds = role.permissions ? role.permissions.map(p => p.id) : [];
                    permCheckboxes.forEach(cb => {
                        cb.checked = assignedIds.includes(parseInt(cb.value));
                    });

                    openRoleForm();
                },
                function(error) { showError('Failed to load role'); }
            );
        }

        function submitRoleForm(e) {
            e.preventDefault();
            const form = document.getElementById('roleForm');
            const roleId = document.getElementById('roleId').value;
            const selectedPerms = Array.from(document.querySelectorAll('[name="permissions"]:checked'))
                .map(cb => parseInt(cb.value));

            const data = {
                libelle: form.querySelector('[name="libelle"]').value,
                description: form.querySelector('[name="description"]').value,
                actif: form.querySelector('[name="actif"]').checked,
                permissionIds: selectedPerms
            };

            const method = roleId ? 'PUT' : 'POST';
            const url = roleId ? '/erp/api/roles/' + roleId : '/erp/api/roles';

            ajaxCall(url, method, data,
                function(response) {
                    showSuccess('Role saved');
                    closeRoleForm();
                    loadRoles();
                },
                function(error) { showError('Failed to save role'); }
            );
        }

        function deleteRole(id) {
            if (!confirm('Are you sure?')) return;
            
            ajaxCall('/erp/api/roles/' + id, 'DELETE', null,
                function(response) {
                    showSuccess('Role deleted');
                    loadRoles();
                },
                function(error) { showError('Failed to delete role'); }
            );
        }
    </script>
</body>
</html>
