(function(it){
  return it();
})(function(){
  /*
  interface
   - e.dataTransfer ( drag data )
     - application/json - json in datadom format
     - mode/<mode> - determine display type. possible values:
       - inline
       - block
  */
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
        var d, mode, data, x$;
        if (!this.mod.dragger.contains(e.target)) {
          return;
        }
        d = this.mod.dragger;
        d.src = e.target;
        mode = /inline/.exec(getComputedStyle(d.src).display) ? 'inline' : 'block';
        data = {
          mode: mode
        };
        x$ = e.dataTransfer;
        x$.setData('application/json', JSON.stringify(data));
        x$.setData("mode/" + mode, '');
        x$.setDragImage(hub.ghost[mode], 10, 10);
        d.setDrag(true);
        return e.stopPropagation();
      },
      dragover: function(e){
        var d, ret, mode, ref$, ref1$;
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
        mode = e.dataTransfer.types.map(function(it){
          return /mode\/(.+)/.exec(it);
        }).filter(function(it){
          return it;
        }).map(function(it){
          return it[1];
        })[0] || 'inline';
        return d.render((ref$ = (ref1$ = {}, ref1$.range = ret.range, ref1$), ref$.mode = mode, ref$));
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
    ghost: {
      block: (ref$ = new Image(), ref$.src = "data:image/svg+xml," + encodeURIComponent("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"15\" viewBox=\"0 0 20 15\">\n<rect x=\"0\" y=\"0\" width=\"9\" height=\"15\" fill=\"rgba(0,0,0,.5)\"/>\n<rect x=\"11\" y=\"0\" width=\"9\" height=\"15\" fill=\"rgba(0,0,0,.5)\"/>\n</svg>"), ref$),
      inline: (ref$ = new Image(), ref$.src = "data:image/svg+xml," + encodeURIComponent("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"15\" viewBox=\"0 0 20 15\">\n<rect x=\"0\" y=\"0\" width=\"20\" height=\"3\" fill=\"rgba(0,0,0,.5)\"/>\n<rect x=\"0\" y=\"4\" width=\"20\" height=\"3\" fill=\"rgba(0,0,0,.5)\"/>\n<rect x=\"0\" y=\"8\" width=\"20\" height=\"3\" fill=\"rgba(0,0,0,.5)\"/>\n<rect x=\"0\" y=\"12\" width=\"20\" height=\"3\" fill=\"rgba(0,0,0,.5)\"/>\n</svg>"), ref$)
    },
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
    hostmatch: function(arg$){
      var parent, mode, type;
      parent = arg$.parent, mode = arg$.mode;
      while (parent) {
        if (parent.hasAttribute) {
          type = 0;
          if (mode === 'block' && parent.hasAttribute('hostable')) {
            type += 1;
          }
          if (mode === 'inline' && parent.hasAttribute('editable') && parent.getAttribute('editable') !== 'false') {
            type += 2;
          }
          if (type) {
            return {
              parent: parent,
              type: type
            };
          }
        }
        if ((parent = parent.parentNode) === this.root) {
          parent = null;
        }
      }
      return {
        parent: parent,
        type: type
      };
    },
    render: function(opt){
      var range, ref$, parent, type, insertable, box;
      opt == null && (opt = {});
      range = opt.range;
      if (!range) {
        return ref$ = this.caret.box.style, ref$.display = 'none', ref$;
      }
      ref$ = this.hostmatch({
        parent: range.startContainer,
        mode: opt.mode
      }), parent = ref$.parent, type = ref$.type;
      insertable = type;
      box = range.getBoundingClientRect();
      this.caret.range = range;
      return import$(this.caret.box.style, {
        left: (box.x + window.pageXOffset) + "px",
        top: (box.y + window.pageYOffset) + "px",
        height: box.height + "px",
        display: 'block',
        opacity: insertable ? 1 : 0.4,
        filter: insertable ? '' : "saturate(0)"
      });
    },
    drop: function(arg$){
      var evt, ref$, range, node, parent, mode, data, json, plugin, this$ = this;
      evt = arg$.evt;
      ref$ = [this.caret.range, this.src], range = ref$[0], node = ref$[1];
      this.src = null;
      this.render();
      if (!(range && this.root.contains(evt.target))) {
        return;
      }
      parent = range.startContainer;
      mode = evt.dataTransfer.types.map(function(it){
        return /mode\/(.+)/.exec(it);
      }).filter(function(it){
        return it;
      }).map(function(it){
        return it[1];
      })[0] || 'inline';
      if (node) {
        return this.insert({
          range: range,
          parent: parent,
          mode: mode,
          node: node
        });
      }
      data = (json = evt.dataTransfer.getData('application/json'))
        ? JSON.parse(json)
        : {};
      if (data.type === 'block') {
        if (!data.dom) {
          return window.bmgr.get(data.name).then(function(it){
            return it.create();
          }).then(function(bi){
            var node;
            node = document.createElement("div");
            bi.attach({
              root: node
            });
            node = node.childNodes[0];
            node.parentNode.removeChild(node);
            node.setAttribute('block', '');
            node.setAttribute('draggable', true);
            return this$.insert({
              range: range,
              parent: parent,
              node: node,
              mode: data.mode || 'block'
            });
          });
        } else {
          plugin = function(){
            var n;
            n = document.createElement('div');
            n.innerText = 'Hello World!';
            return {
              node: n
            };
          };
          return datadom.deserialize(data.dom, plugin).then(function(ret){
            var n;
            n = ret.node;
            n.setAttribute('editable', true);
            n.setAttribute('draggable', true);
            return this$.insert({
              range: range,
              parent: parent,
              node: ret.node,
              mode: data.mode || 'block'
            });
          });
        }
      } else {
        node = document.createElement(data.mode === 'block' ? 'div' : 'span');
        node.setAttribute('editable', true);
        node.setAttribute('draggable', true);
        datadom.deserialize(data.dom || {}).then(function(ret){
          node.innerHTML = "";
          return node.appendChild(ret.node);
        });
        return this.insert({
          range: range,
          parent: parent,
          node: node,
          mode: data.mode || 'block'
        });
      }
    },
    insert: function(arg$){
      var parent, range, node, mode, ref$, p, r, n, m, sc, so, ta, type, text, r1, r2, lstr, rstr;
      parent = arg$.parent, range = arg$.range, node = arg$.node, mode = arg$.mode;
      ref$ = [parent, range, node, mode], p = ref$[0], r = ref$[1], n = ref$[2], m = ref$[3];
      sc = range.startContainer;
      so = range.startOffset;
      ta = sc.nodeType === Element.TEXT_NODE
        ? sc
        : sc.childNodes[so];
      if (ld$.parent(ta, null, n)) {
        return;
      }
      ref$ = this.hostmatch({
        parent: p,
        mode: m
      }), parent = ref$.parent, type = ref$.type;
      if (!(p = parent)) {
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
        if (mode === 'block') {
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