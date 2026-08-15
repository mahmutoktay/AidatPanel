/**
 * AidatPanel landing tema — localStorage kalıcılığı.
 * Anahtar: aidatpanel-theme = "dark" | "light"
 * Sınıf: html.dark-mode (FOUC önlemek için head'de theme-boot inline de çalışır)
 */
(function () {
  var STORAGE_KEY = 'aidatpanel-theme';
  var ACCENT = '#F86000';

  function isDark() {
    return document.documentElement.classList.contains('dark-mode');
  }

  function setIcon(btn) {
    if (!btn) return;
    var icon = btn.querySelector('i');
    if (!icon) return;
    if (isDark()) {
      icon.classList.remove('fa-moon');
      icon.classList.add('fa-sun');
      icon.style.color = ACCENT;
      btn.setAttribute('aria-pressed', 'true');
      btn.title = 'Gündüz modu';
    } else {
      icon.classList.remove('fa-sun');
      icon.classList.add('fa-moon');
      icon.style.color = '';
      btn.setAttribute('aria-pressed', 'false');
      btn.title = 'Gece modu';
    }
  }

  function apply(mode, persist) {
    var dark = mode === 'dark';
    document.documentElement.classList.toggle('dark-mode', dark);
    document.body.classList.toggle('dark-mode', dark);
    if (persist) {
      try {
        localStorage.setItem(STORAGE_KEY, dark ? 'dark' : 'light');
      } catch (e) { /* ignore */ }
    }
    setIcon(document.getElementById('theme-toggle'));
  }

  function readStored() {
    try {
      return localStorage.getItem(STORAGE_KEY);
    } catch (e) {
      return null;
    }
  }

  function init() {
    var stored = readStored();
    if (stored === 'dark' || stored === 'light') {
      apply(stored, false);
    } else {
      apply(isDark() ? 'dark' : 'light', false);
    }

    var btn = document.getElementById('theme-toggle');
    if (btn) {
      btn.addEventListener('click', function () {
        apply(isDark() ? 'light' : 'dark', true);
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
