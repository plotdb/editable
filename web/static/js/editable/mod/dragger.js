(function(it){
  return it();
})(function(){
  var hub, ref$, dragger;
  hub = {
    events: {
      mousedown: function(e){
        var n;
        n = e.target;
        while (n && (!n.hasAttribute && n.hasAttribute('draggable'))) {
          n = n.parentNode;
        }
        if (n) {
          return n.setAttribute('draggable', true);
        }
      },
      dragstart: function(e){
        var d, src;
        d = this.mod.dragger;
        src = e.target;
        e.dataTransfer.setData('application/json', JSON.stringify({}));
        e.dataTransfer.setDragImage(hub.ghost, 10, 10);
        d.setDrag(true);
        return e.stopPropagation();
      },
      dragover: function(e){
        var d, ret;
        d = this.mod.dragger;
        ret = ldCaret.byPtr({
          node: document.body,
          x: e.clientX,
          y: e.clientY
        });
        if (!d.contains(ret.range.startContainer)) {
          return;
        }
        d.render(ret.range);
        return e.preventDefault();
      },
      drop: function(e){
        var ref$, n, d, json, data;
        ref$ = [e.target, this.mod.dragger], n = ref$[0], d = ref$[1];
        if (!d.contains(n)) {
          return;
        }
        if (json = e.dataTransfer.getData('application/json')) {
          data = JSON.parse(json);
        }
        d.render();
        d.setDrag(false);
        return e.preventDefault();
      }
    },
    ghost: (ref$ = new Image(), ref$.src = "data:image/svg+xml," + encodeURIComponent("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"15\" viewBox=\"0 0 20 15\">\n<rect x=\"0\" y=\"0\" width=\"20\" height=\"15\" fill=\"rgba(0,0,0,.5)\"/>\n</svg>"), ref$),
    init: function(){
      return this.mod.dragger = new dragger({
        root: this.root
      });
    }
  };
  dragger = function(opt){
    var root;
    opt == null && (opt = {});
    this.opt = opt;
    root = opt.root;
    this.root = root = typeof root === 'string'
      ? document.querySelector(root)
      : root ? root : null;
    import$(this, {
      dragging: false,
      caret: null,
      src: null
    });
    this.caret = {
      box: null,
      range: null
    };
    this.evtHandler = {};
    this.init();
    return this;
  };
  dragger.prototype = import$(Object.create(Object.prototype), {
    init: function(){
      this.caret.box = document.createElement("div");
      import$(this.caret.box.style, {
        position: 'fixed',
        left: 0,
        top: 0,
        display: 'none',
        border: '2px solid #f0f',
        pointerEvents: 'none',
        transition: "opacity .15s ease-in-out",
        animation: "blink .4s linear infinite"
      });
      return document.body.appendChild(this.caret.box);
    },
    contains: function(n){
      return this.root.contains(n);
    },
    setDrag: function(it){
      return this.dragging = it;
    },
    render: function(r){
      var ref$, box;
      if (!r) {
        return ref$ = this.caret.box.style, ref$.display = 'none', ref$;
      }
      box = r.getBoundingClientRect();
      return import$(this.caret.box.style, {
        left: box.x + "px",
        top: box.y + "px",
        height: box.height + "px",
        width: '2px',
        position: 'absolute',
        border: "2px solid #f00",
        display: 'block'
      });
    }
  });
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('dragger', hub);
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}