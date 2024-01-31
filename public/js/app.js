// Update your existing JavaScript code with the following

document.getElementById('menuToggle').addEventListener('click', function() {
    const menu = document.getElementById('menu');
    const menuOverlay = document.getElementById('menu-overlay');

    // Toggle the class to enable or disable the transition
    menu.classList.toggle('menu-open');
    menuOverlay.style.display = menu.classList.contains('menu-open') ? 'block' : 'none';
});

document.getElementById('closeMenu').addEventListener('click', function() {
    const menu = document.getElementById('menu');
    const menuOverlay = document.getElementById('menu-overlay');

    // Toggle the class to enable or disable the transition
    menu.classList.toggle('menu-open');
    menuOverlay.style.display = 'none';
});