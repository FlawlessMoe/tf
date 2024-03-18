document.getElementById('menuToggle').addEventListener('click', function() {
    const menu = document.getElementById('menu');
    const menuOverlay = document.getElementById('menu-overlay');

    menu.classList.toggle('menu-open');
    menuOverlay.style.display = menu.classList.contains('menu-open') ? 'block' : 'none';
});

document.getElementById('closeMenu').addEventListener('click', function() {
    const menu = document.getElementById('menu');
    const menuOverlay = document.getElementById('menu-overlay');

    menu.classList.toggle('menu-open');
    menuOverlay.style.display = 'none';
});

// --------------------------- //