(function(it){
  return it();
})(function(){
  var hide, mod, ref$;
  hide = function(node){
    return import$(node.style, {
      pointerEvents: 'none',
      opacity: 0
    });
  };
  mod = {
    events: {
      mousedown: function(){
        return hide(this.div);
      },
      contextmenu: function(e){
        var x, y, k;
        e.preventDefault();
        x = e.clientX;
        y = e.clientY;
        import$(this.div.style, {
          pointerEvents: 'all',
          opacity: 1,
          left: x + "px",
          top: y + "px"
        });
        return this.div.innerHTML = (function(){
          var results$ = [];
          for (k in this.contextmenu) {
            results$.push(k);
          }
          return results$;
        }.call(this)).map(function(it){
          return "<div>" + it + "</div>";
        }).join('');
      }
    },
    contextmenu: {
      name: 'context menu',
      list: {
        name: 'hello world'
      }
    },
    init: function(){
      this.div = ld$.create({
        name: 'div'
      });
      this.div.innerText = ' ... ';
      import$(this.div.style, {
        position: 'absolute',
        cursor: 'pointer',
        pointerEvents: 'none',
        opacity: 0,
        transition: 'opacity .15s ease-out',
        padding: '.5em 1em',
        border: '1px solid #e1e2e3',
        borderRadius: '.25em',
        boxShadow: '0 3px 3px rgba(0,0,0,.1)',
        background: '#fff',
        zIndex: 10000
      });
      this.div.addEventListener('mousedown', function(e){
        e.preventDefault();
        return e.stopPropagation();
      });
      this.div.addEventListener('click', function(e){
        return hide(this);
      });
      return document.body.appendChild(this.div);
    }
  };
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('context', mod);
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}