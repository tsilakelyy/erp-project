<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>New Customer - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - New Customer</span>
    </nav>

    <div class="container mt-4">
        <form method="POST" action="/erp-system/customers">
            <div class="mb-3">
                <label class="form-label">Code *</label>
                <input type="text" class="form-control" name="code" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Name *</label>
                <input type="text" class="form-control" name="name" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Email</label>
                <input type="email" class="form-control" name="email">
            </div>

            <div class="mb-3">
                <label class="form-label">Phone</label>
                <input type="text" class="form-control" name="phone">
            </div>

            <div class="mb-3">
                <label class="form-label">Address</label>
                <input type="text" class="form-control" name="address">
            </div>

            <div class="mb-3">
                <label class="form-label">City</label>
                <input type="text" class="form-control" name="city">
            </div>

            <div class="mb-3">
                <label class="form-label">Payment Terms (Days)</label>
                <input type="number" class="form-control" name="paymentTermsDays" value="30">
            </div>

            <button type="submit" class="btn btn-primary">Create</button>
            <a href="/erp-system/customers" class="btn btn-secondary">Cancel</a>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
