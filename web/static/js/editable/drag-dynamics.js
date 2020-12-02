var hub, dragger;
hub = {
  list: [],
  add: function(it){
    this.init();
    return this.list.push(it);
  },
  host: function(n){
    var host;
    return host = this.list.filter(function(it){
      return it.root.contains(n);
    })[0];
  },
  init: function(){
    var this$ = this;
    if (this.inited) {
      return;
    }
    this.inited = true;
    hub.ghost = new Image();
    hub.ghost.src = "data:image/svg+xml," + encodeURIComponent("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"15\" viewBox=\"0 0 20 15\">\n<rect x=\"0\" y=\"0\" width=\"20\" height=\"15\" fill=\"rgba(0,0,0,.5)\"/>\n</svg>");
    document.addEventListener('mousedown', function(e){
      var n;
      n = e.target;
      while (n && (!n.hasAttribute && n.hasAttribute('draggable'))) {
        n = n.parentNode;
      }
      if (n) {
        return n.setAttribute('draggable', true);
      }
    });
    document.addEventListener('dragstart', function(e){
      var src;
      src = e.target;
      e.dataTransfer.setData('application/json', JSON.stringify({}));
      e.dataTransfer.setDragImage(hub.ghost, 10, 10);
      hub.dragging = true;
      return e.stopPropagation();
    });
    document.addEventListener('dragover', function(e){
      var ret, host;
      ret = ldCaret.byPtr({
        node: document.body,
        x: e.clientX,
        y: e.clientY
      });
      if (!(host = this$.host(ret.range.startContainer))) {
        return;
      }
      host.render(ret.range);
      return e.preventDefault();
    });
    return document.addEventListener('drop', function(e){
      var n, json, data, host;
      n = e.target;
      if (json = e.dataTransfer.getData('application/json')) {
        data = JSON.parse(json);
      }
      if (!(host = this$.host(n))) {
        return;
      }
      host.render();
      hub.dragging = false;
      return e.preventDefault();
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
    document.body.appendChild(this.caret.box);
    return hub.add(this);
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
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}