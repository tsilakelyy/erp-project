document.addEventListener('DOMContentLoaded', function() {
    var links = document.querySelectorAll('[data-flip-target]');
    if (!links || links.length === 0) return;

    links.forEach(function(link) {
        link.addEventListener('click', function(event) {
            event.preventDefault();
            var target = link.getAttribute('data-flip-target');
            if (!target) return;
            var card = document.querySelector('.login-flip-card');
            var duration = 820;
            if (card) {
                card.setAttribute('aria-busy', 'true');
                card.style.pointerEvents = 'none';
                window.requestAnimationFrame(function() {
                    card.classList.add('is-flipping');
                });
                setTimeout(function() {
                    window.location.href = target;
                }, duration);
            } else {
                window.location.href = target;
            }
        });
    });
});
