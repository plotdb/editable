(function(it){
  return it();
})(function(){
  var hub, ref$, dragger;
  hub = {
    events: {
      mousedown: function(e){
        var n;
        if (!this.mod.dragger.contains(e.target)) {
          return;
        }
        n = e.target;
        while (n && !(n.hasAttribute && n.hasAttribute('draggable'))) {
          n = n.parentNode;
        }
        if (n) {
          return n.setAttribute('draggable', true);
        }
      },
      dragstart: function(e){
        var d;
        d = this.mod.dragger;
        d.src = e.target;
        e.dataTransfer.setData('application/json', JSON.stringify({}));
        e.dataTransfer.setDragImage(hub.ghost, 10, 10);
        d.setDrag(true);
        return e.stopPropagation();
      },
      dragover: function(e){
        var d, ret;
        e.preventDefault();
        d = this.mod.dragger;
        ret = ldCaret.byPtr({
          node: this.root,
          x: e.clientX,
          y: e.clientY,
          method: 'euclidean'
        });
        if (!d.contains(ret.range.startContainer)) {
          return;
        }
        return d.render({
          range: ret.range
        });
      },
      drop: function(e){
        var ref$, n, d;
        ref$ = [e.target, this.mod.dragger], n = ref$[0], d = ref$[1];
        e.preventDefault();
        return d.drop({
          evt: e
        });
      }
    },
    ghost: (ref$ = new Image(), ref$.src = "data:image/svg+xml," + encodeURIComponent("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"15\" viewBox=\"0 0 20 15\">\n<rect x=\"0\" y=\"0\" width=\"20\" height=\"15\" fill=\"rgba(0,0,0,.5)\"/>\n</svg>"), ref$),
    init: function(){
      return this.mod.dragger = new dragger({
        root: this.root,
        editable: this
      });
    }
  };
  dragger = function(opt){
    var root;
    opt == null && (opt = {});
    this.editable = opt.editable;
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
      this.caret.box.classList.add('mod-dragger-caret');
      return document.body.appendChild(this.caret.box);
    },
    contains: function(n){
      return this.root.contains(n);
    },
    setDrag: function(it){
      return this.dragging = it;
    },
    typematch: function(arg$){
      var n, p, type, display;
      n = arg$.n, p = arg$.p;
      if (!(n && p)) {
        return 0;
      }
      type = 0;
      display = n ? getComputedStyle(n).display : void 8;
      if (p.hasAttribute('hostable') && !/inline/.exec(display)) {
        type += 1;
      }
      if (p.hasAttribute('editable') && p.getAttribute('editable') !== 'false' && /inline/.exec(display)) {
        type += 2;
      }
      return type;
    },
    render: function(opt){
      var range, ref$, p, insertable, box;
      opt == null && (opt = {});
      range = opt.range;
      if (!range) {
        return ref$ = this.caret.box.style, ref$.display = 'none', ref$;
      }
      p = ld$.parent(range.startContainer, "[hostable],[editable]:not([editable=false])", this.root);
      insertable = this.typematch({
        p: p,
        n: this.src
      });
      box = range.getBoundingClientRect();
      this.caret.range = range;
      return import$(this.caret.box.style, {
        left: box.x + "px",
        top: box.y + "px",
        height: box.height + "px",
        display: 'block',
        opacity: insertable ? 1 : 0.4,
        filter: insertable ? '' : "saturate(0)"
      });
    },
    drop: function(arg$){
      var evt, range, p, sc, so, ta, n, data, json, type, text, this$ = this;
      evt = arg$.evt;
      range = this.caret.range;
      this.render();
      if (!(range && this.root.contains(evt.target))) {
        return;
      }
      p = ld$.parent(range.startContainer, "[hostable],[editable]:not([editable=false])", this.root);
      if (!p) {
        return;
      }
      sc = range.startContainer;
      so = range.startOffset;
      ta = sc.nodeType === Element.TEXT_NODE
        ? sc
        : sc.childNodes[so];
      n = this.src;
      if (!n) {
        data = (json = evt.dataTransfer.getData('application/json'))
          ? JSON.parse(json)
          : {};
        if (data.type === 'block') {
          return blocktmp.get({
            name: data.data.name
          }).then(function(dom){
            return deserialize(dom);
          }).then(function(ret){
            ta.parentNode.insertBefore(ret.node, ta);
            return this$.editable.fire('change');
          })['catch'](function(it){
            return console.log(it);
          });
        }
      } else {
        if (ld$.parent(ta, null, n)) {
          return;
        }
        if (!(type = this.typematch({
          p: p,
          n: n
        }))) {
          return;
        }
        if (type & 1) {
          while (ta) {
            if (ta.parentNode === p) {
              break;
            }
            ta = ta.parentNode;
          }
        }
        if (ta.nodeType === Element.TEXT_NODE) {
          n.parentNode.removeChild(n);
          text = ta.textContent;
          [document.createTextNode(text.substring(0, so)), n, document.createTextNode(text.substring(so))].map(function(it){
            return ta.parentNode.insertBefore(it, ta);
          });
          ta.parentNode.removeChild(ta);
        } else {
          n.parentNode.removeChild(n);
          ta.parentNode.insertBefore(n, ta);
        }
        return this.editable.fire('change');
      }
    }
  });
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('dragger', hub);
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}