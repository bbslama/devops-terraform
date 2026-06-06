document.getElementById('actionBtn').addEventListener('click', function() {
    const msg = document.getElementById('message');
    if (msg.classList.contains('hidden')) {
        msg.classList.replace('hidden', 'visible');
    } else {
        msg.classList.replace('visible', 'hidden');
    }
});

