(function(){
  var btn = document.querySelector('.menu-toggle');
  var nav = document.querySelector('.navlinks');
  if(!btn || !nav) return;
  btn.setAttribute('aria-expanded','false');
  btn.addEventListener('click', function(){
    var open = nav.classList.toggle('open');
    btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    btn.textContent = open ? '✕' : '☰';
  });
  nav.querySelectorAll('a').forEach(function(a){
    a.addEventListener('click', function(){
      nav.classList.remove('open');
      btn.setAttribute('aria-expanded','false');
      btn.textContent = '☰';
    });
  });
})();
