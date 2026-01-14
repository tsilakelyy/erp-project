<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customer Detail - ERP</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <span class="navbar-brand mb-0 h1">ERP - ${customer.name}</span>
    </nav>

    <div class="container mt-4">
        <dl class="row">
            <dt class="col-sm-3">Code:</dt>
            <dd class="col-sm-9">${customer.code}</dd>

            <dt class="col-sm-3">Name:</dt>
            <dd class="col-sm-9">${customer.name}</dd>

            <dt class="col-sm-3">Email:</dt>
            <dd class="col-sm-9">${customer.email}</dd>

            <dt class="col-sm-3">Phone:</dt>
            <dd class="col-sm-9">${customer.phone}</dd>

            <dt class="col-sm-3">Address:</dt>
            <dd class="col-sm-9">${customer.address}</dd>

            <dt class="col-sm-3">City:</dt>
            <dd class="col-sm-9">${customer.city}</dd>

            <dt class="col-sm-3">Payment Terms:</dt>
            <dd class="col-sm-9">${customer.paymentTermsDays} days</dd>
        </dl>

        <a href="/erp-system/customers" class="btn btn-secondary">Back</a>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
