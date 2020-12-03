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
        if (!this.mod.dragger.contains(e.target)) {
          return;
        }
        d = this.mod.dragger;
        d.src = e.target;
        e.dataTransfer.setData('application/json', JSON.stringify({}));
        e.dataTransfer.setDragImage(hub.ghost, 10, 10);
        d.setDrag(true);
        return e.stopPropagation();
      },
      dragover: function(e){
        var d, ret, ref$;
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
        return d.render((ref$ = {
          display: 'inline'
        }, ref$.range = ret.range, ref$));
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
      var node, parent, display, ref$, n, p, d, type;
      node = arg$.node, parent = arg$.parent, display = arg$.display;
      ref$ = [node, parent, display, 0], n = ref$[0], p = ref$[1], d = ref$[2], type = ref$[3];
      if (!(p && (n || d))) {
        return 0;
      }
      d = (d
        ? d
        : n ? getComputedStyle(n).display : '') || 'inline';
      if (p.hasAttribute('hostable') && !/inline/.exec(d)) {
        type += 1;
      }
      if (p.hasAttribute('editable') && p.getAttribute('editable') !== 'false' && /inline/.exec(d)) {
        type += 2;
      }
      return type;
    },
    render: function(opt){
      var range, ref$, parent, insertable, box;
      opt == null && (opt = {});
      range = opt.range;
      if (!range) {
        return ref$ = this.caret.box.style, ref$.display = 'none', ref$;
      }
      parent = ld$.parent(range.startContainer, "[hostable],[editable]:not([editable=false])", this.root);
      insertable = this.typematch(import$({
        parent: parent
      }, this.src
        ? {
          node: this.src
        }
        : {
          display: opt.display
        }));
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
      var evt, range, parent, data, json, node, this$ = this;
      evt = arg$.evt;
      range = this.caret.range;
      this.render();
      if (!(range && this.root.contains(evt.target))) {
        return;
      }
      parent = ld$.parent(range.startContainer, "[hostable],[editable]:not([editable=false])", this.root);
      if (!parent) {
        return;
      }
      if (this.src) {
        return this.insert({
          range: range,
          parent: parent,
          node: this.src
        });
      }
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
      } else {
        node = document.createElement(data.display === 'block' ? 'div' : 'span');
        node.innerText = JSON.stringify(data);
        return this.insert({
          range: range,
          parent: parent,
          node: node,
          display: data.display || 'inline'
        });
      }
    },
    insert: function(arg$){
      var parent, range, node, display, ref$, p, r, n, d, sc, so, ta, type, text, r1, r2, lstr, rstr;
      parent = arg$.parent, range = arg$.range, node = arg$.node, display = arg$.display;
      ref$ = [parent, range, node, display], p = ref$[0], r = ref$[1], n = ref$[2], d = ref$[3];
      sc = range.startContainer;
      so = range.startOffset;
      ta = sc.nodeType === Element.TEXT_NODE
        ? sc
        : sc.childNodes[so];
      if (ld$.parent(ta, null, n)) {
        return;
      }
      if (!(type = this.typematch({
        parent: p,
        node: n,
        display: d
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
        if (n.parentNode) {
          n.parentNode.removeChild(n);
        }
        text = ta.textContent;
        [document.createTextNode(text.substring(0, so)), n, document.createTextNode(text.substring(so))].map(function(it){
          return ta.parentNode.insertBefore(it, ta);
        });
        ta.parentNode.removeChild(ta);
      } else {
        if (n.parentNode) {
          n.parentNode.removeChild(n);
        }
        if (display === 'block') {
          r1 = document.createRange();
          r2 = document.createRange();
          r1.setStart(p, 0);
          r1.setEnd(sc, so);
          r2.setStart(sc, so);
          r2.setEnd(p.nextSibling || p, p.nextSibling
            ? 0
            : p.childNodes
              ? p.childNodes.length
              : p.textContent.length);
          lstr = r1.toString().length;
          rstr = r2.toString().length;
          if (lstr > rstr) {
            ta.parentNode.insertBefore(n, ta.nextSibling);
          } else {
            ta.parentNode.insertBefore(n, ta);
          }
        } else {
          ta.parentNode.insertBefore(n, ta);
        }
      }
      return this.editable.fire('change');
    }
  });
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('dragger', hub);
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}