(function () {
  var PLAY_STORE =
    'https://play.google.com/store/apps/details?id=com.aidatpanel.app';
  var APP_STORE = 'https://apps.apple.com/tr/app/aidatpanel/id000000000';
  var JOIN_BASE = 'https://aidatpanel.com/join';
  var INVITE_CODE_RE = /^AP[0-9A-F]-[0-9A-F]{3}-[0-9A-F]{4}$/;

  var params = new URLSearchParams(window.location.search);
  var raw = params.get('code') || '';
  var code = raw.trim().toUpperCase().replace(/\s+/g, '');
  var valid = INVITE_CODE_RE.test(code);

  var joinUrl = valid
    ? JOIN_BASE + '?code=' + encodeURIComponent(code)
    : JOIN_BASE;
  var customUrl = valid
    ? 'aidatpanel://join?code=' + encodeURIComponent(code)
    : 'aidatpanel://join';

  var openBtn = document.getElementById('open-app');
  openBtn.href = joinUrl;

  if (valid) {
    document.getElementById('code-wrap').hidden = false;
    document.getElementById('code-display').textContent = code;
  } else if (!raw) {
    var errorEl = document.getElementById('error');
    errorEl.hidden = false;
    errorEl.textContent =
      'Davet kodu bulunamadı. Yöneticinizden yeni bağlantı isteyin.';
    openBtn.classList.add('btn-primary');
    openBtn.classList.remove('btn-accent');
    openBtn.textContent = 'Ana sayfaya dön';
    openBtn.href = '../index.html';
  } else {
    var invalidEl = document.getElementById('error');
    invalidEl.hidden = false;
    invalidEl.textContent = 'Geçersiz davet bağlantısı. Kodu kontrol edip tekrar deneyin.';
  }

  openBtn.addEventListener('click', function (e) {
    if (!valid) return;
    var isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
    if (isMobile) {
      e.preventDefault();
      window.location.href = customUrl;
      window.setTimeout(function () {
        window.location.href = joinUrl;
      }, 600);
    }
  });

  document.getElementById('play-store').href = PLAY_STORE;
  document.getElementById('app-store').href = APP_STORE;
})();
