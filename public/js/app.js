document.getElementById('menuToggle').addEventListener('click', function() {
    document.getElementById('menu').style.left = '0';
    document.getElementById('menu-overlay').style.display = 'block'; // Show overlay
});

document.getElementById('closeMenu').addEventListener('click', function() {
    document.getElementById('menu').style.left = '-250px';
    document.getElementById('menu-overlay').style.display = 'none'; // Hide overlay
});