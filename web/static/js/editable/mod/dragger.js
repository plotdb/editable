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
          node: document.body,
          x: e.clientX,
          y: e.clientY
        });
        if (!d.contains(ret.range.startContainer)) {
          return;
        }
        return d.render(ret.range);
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
    render: function(r){
      var ref$, box;
      if (!r) {
        return ref$ = this.caret.box.style, ref$.display = 'none', ref$;
      }
      box = r.getBoundingClientRect();
      this.caret.range = r;
      return import$(this.caret.box.style, {
        left: box.x + "px",
        top: box.y + "px",
        height: box.height + "px",
        display: 'block'
      });
    },
    drop: function(arg$){
      var evt, range, sc, so, ta, n, data, json, text, this$ = this;
      evt = arg$.evt;
      range = this.caret.range;
      this.render(null);
      if (!(range && this.root.contains(evt.target))) {
        return;
      }
      sc = range.startContainer;
      so = range.startOffset;
      ta = sc.nodeType === Element.TEXT_NODE
        ? sc
        : sc.childNodes[so];
      if (!(n = this.src)) {
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