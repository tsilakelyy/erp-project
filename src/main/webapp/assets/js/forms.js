/* Form Handling JavaScript */

function validateForm(formId) {
    const form = document.getElementById(formId);
    if (!form) return true;

    let isValid = true;
    const inputs = form.querySelectorAll('[data-validate]');

    inputs.forEach(input => {
        const validators = input.getAttribute('data-validate').split(',');
        let fieldValid = true;

        for (const validator of validators) {
            const rule = validator.trim();
            if (rule === 'required' && !input.value.trim()) {
                fieldValid = false;
                break;
            }
            if (rule === 'email' && !isValidEmail(input.value)) {
                fieldValid = false;
                break;
            }
            if (rule === 'number' && isNaN(input.value)) {
                fieldValid = false;
                break;
            }
            if (rule.startsWith('minlength:')) {
                const minLen = parseInt(rule.split(':')[1]);
                if (input.value.length < minLen) {
                    fieldValid = false;
                    break;
                }
            }
        }

        if (!fieldValid) {
            input.classList.add('error');
            isValid = false;
        } else {
            input.classList.remove('error');
        }
    });

    return isValid;
}

function isValidEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

function resetForm(formId) {
    const form = document.getElementById(formId);
    if (form) {
        form.reset();
        form.querySelectorAll('.error').forEach(el => el.classList.remove('error'));
    }
}

function submitForm(formId, url, method = 'POST', callback) {
    if (!validateForm(formId)) {
        showError('Veuillez corriger les erreurs du formulaire');
        return;
    }

    const form = document.getElementById(formId);
    const formData = new FormData(form);
    const data = Object.fromEntries(formData);

    ajaxCall(url, method, data,
        (response) => {
            showSuccess('Formulaire soumis avec succes');
            if (callback) callback(response);
        },
        (error) => {
            showError(error.message || 'Erreur lors de la soumission');
        }
    );
}

function populateDropdown(selectId, dataUrl, valueField = 'id', labelField = 'name') {
    const select = document.getElementById(selectId);
    if (!select) return;

    ajaxCall(dataUrl, 'GET', null,
        (data) => {
            select.innerHTML = '<option value="">-- Selectionner --</option>';
            (Array.isArray(data) ? data : data.content || []).forEach(item => {
                const option = document.createElement('option');
                option.value = item[valueField];
                option.textContent = item[labelField];
                select.appendChild(option);
            });
        },
        (error) => {
            console.error('Erreur de chargement de la liste:', error);
        }
    );
}

function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'block';
        modal.classList.add('show');
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'none';
        modal.classList.remove('show');
    }
}

function closeAllModals() {
    document.querySelectorAll('[role="dialog"]').forEach(modal => {
        modal.style.display = 'none';
        modal.classList.remove('show');
    });
}

// Format number as currency
function formatCurrency(value) {
    return new Intl.NumberFormat('fr-MG', {
        style: 'currency',
        currency: 'MGA'
    }).format(value);
}

// Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-MG');
}

// Initialize form handlers on document load
document.addEventListener('DOMContentLoaded', () => {
    // Auto-validate on blur
    document.querySelectorAll('[data-validate]').forEach(input => {
        input.addEventListener('blur', function() {
            validateField(this.id);
        });
    });
});

function validateField(fieldId) {
    const field = document.getElementById(fieldId);
    if (!field || !field.getAttribute('data-validate')) return true;

    const validators = field.getAttribute('data-validate').split(',');
    let isValid = true;

    for (const validator of validators) {
        const rule = validator.trim();
        if (rule === 'required' && !field.value.trim()) {
            isValid = false;
            break;
        }
        if (rule === 'email' && !isValidEmail(field.value)) {
            isValid = false;
            break;
        }
    }

    if (!isValid) {
        field.classList.add('error');
    } else {
        field.classList.remove('error');
    }

    return isValid;
}
