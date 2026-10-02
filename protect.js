// ============================================================
// Protection basique des images (logos, favicon, fond)
// Bloque : clic droit, glisser-déposer, sélection, et quelques
// raccourcis clavier courants. Non infaillible, mais dissuasif
// pour la grande majorité des visiteurs.
// Peut être désactivée dynamiquement (ex: pour le superadmin)
// via window.disableImageProtection().
// ============================================================

(function () {
  function onContextMenu(e) { e.preventDefault(); }
  function onDragStart(e) { if (e.target.tagName === 'IMG') e.preventDefault(); }
  function onKeyDown(e) {
    const key = e.key.toLowerCase();
    const blocked =
      e.key === 'F12' ||
      (e.ctrlKey && e.shiftKey && ['i', 'j', 'c'].includes(key)) ||
      (e.ctrlKey && ['s', 'u'].includes(key));
    if (blocked) e.preventDefault();
  }

  const protectStyle = document.createElement('style');
  protectStyle.id = 'image-protect-style';
  protectStyle.textContent = `
    img {
      -webkit-user-select: none;
      -moz-user-select: none;
      user-select: none;
      -webkit-user-drag: none;
      -webkit-touch-callout: none;
      pointer-events: auto;
    }
  `;

  function enableImageProtection() {
    document.addEventListener('contextmenu', onContextMenu);
    document.addEventListener('dragstart', onDragStart);
    document.addEventListener('keydown', onKeyDown);
    if (!document.getElementById('image-protect-style')) {
      document.head.appendChild(protectStyle);
    }
  }

  function disableImageProtection() {
    document.removeEventListener('contextmenu', onContextMenu);
    document.removeEventListener('dragstart', onDragStart);
    document.removeEventListener('keydown', onKeyDown);
    const el = document.getElementById('image-protect-style');
    if (el) el.remove();
  }

  window.enableImageProtection = enableImageProtection;
  window.disableImageProtection = disableImageProtection;

  enableImageProtection();
})();
