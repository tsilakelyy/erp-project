// Modal dialog management utilities
class Modal {
    static create(id, title, content, buttons = []) {
        let modal = document.getElementById(id);
        
        if (!modal) {
            modal = document.createElement('div');
            modal.id = id;
            modal.className = 'modal';
            document.body.appendChild(modal);
        }

        const html = `
            <div class="modal-content">
                <div class="modal-header">
                    <h3>${title}</h3>
                    <button class="modal-close" onclick="Modal.close('${id}')">&times;</button>
                </div>
                <div class="modal-body">
                    ${content}
                </div>
                <div class="modal-footer">
                    ${buttons.map(btn => 
                        `<button class="btn ${btn.class}" onclick="${btn.onclick}">${btn.text}</button>`
                    ).join('')}
                </div>
            </div>
        `;

        modal.innerHTML = html;
        return modal;
    }

    static open(id) {
        const modal = document.getElementById(id);
        if (modal) {
            modal.style.display = 'block';
            modal.classList.add('show');
        }
    }

    static close(id) {
        const modal = document.getElementById(id);
        if (modal) {
            modal.style.display = 'none';
            modal.classList.remove('show');
        }
    }

    static confirm(title, message, onConfirm, onCancel) {
        const modal = this.create('confirm-modal', title, message, [
            { text: 'Confirm', class: 'btn-primary', onclick: `Modal.close('confirm-modal'); (${onConfirm})()` },
            { text: 'Cancel', class: 'btn-secondary', onclick: `Modal.close('confirm-modal'); ${onCancel ? `(${onCancel})()` : ''}` }
        ]);
        this.open('confirm-modal');
    }

    static alert(title, message) {
        const modal = this.create('alert-modal', title, message, [
            { text: 'OK', class: 'btn-primary', onclick: "Modal.close('alert-modal')" }
        ]);
        this.open('alert-modal');
    }

    static prompt(title, label, onSubmit) {
        const inputId = 'prompt-input-' + Date.now();
        const content = `<label>${label}</label><input type="text" id="${inputId}" class="form-control">`;
        const modal = this.create('prompt-modal', title, content, [
            { text: 'OK', class: 'btn-primary', onclick: `Modal.submitPrompt('${inputId}', ${onSubmit})` },
            { text: 'Cancel', class: 'btn-secondary', onclick: "Modal.close('prompt-modal')" }
        ]);
        this.open('prompt-modal');
    }

    static submitPrompt(inputId, callback) {
        const value = document.getElementById(inputId).value;
        this.close('prompt-modal');
        if (callback) callback(value);
    }
}

// Usage:
// Modal.confirm('Delete?', 'Are you sure?', () => deleteItem(id), () => console.log('Cancelled'));
// Modal.alert('Success', 'Item saved successfully');
// Modal.prompt('Enter Name', 'Your name:', (value) => console.log(value));
