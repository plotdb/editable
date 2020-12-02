(function(it){
  return it();
})(function(){
  var contenteditable, ce, setEditable, backspaceFix;
  contenteditable = ce = {
    events: {
      mousedown: function(e){
        return this.mod.contenteditable.drag = false;
      },
      mousemove: function(e){
        if (e.buttons === 1) {
          return this.mod.contenteditable.drag = true;
        }
      },
      keydown: function(e){
        return backspaceFix.call(this, e);
      },
      click: function(e){
        return setEditable.call(this, {
          target: e.target,
          x: e.clientX,
          y: e.clientY
        });
      },
      keyup: function(e){
        if (e.which === 27) {
          return ce.setEditable.call(this, {
            target: null
          });
        }
      }
    },
    init: function(){
      var k, v, this$ = this;
      this.mod.contenteditable = {};
      return (function(){
        var ref$, results$ = [];
        for (k in ref$ = ce.events) {
          v = ref$[k];
          results$.push({
            k: k,
            v: v
          });
        }
        return results$;
      }()).map(function(arg$){
        var k, v;
        k = arg$.k, v = arg$.v;
        return document.addEventListener(k, function(e){
          return v.call(this$, e);
        });
      });
    }
  };
  contenteditable.setEditable = setEditable = function(arg$){
    var target, x, y, lc, ct, delay, p, sel, r, range, n;
    target = arg$.target, x = arg$.x, y = arg$.y;
    lc = this.mod.contenteditable;
    ct = contenteditable.ct;
    contenteditable.ct = Date.now();
    delay = ct != null ? contenteditable.ct - ct : 1000;
    p = ld$.parent(target, '[editable]');
    if (!ld$.parent(p, null, this.root)) {
      p = null;
    }
    if (lc.lock && lc.active !== p) {
      p = null;
    }
    if (lc.active && lc.active !== p) {
      lc.active.setAttribute('contenteditable', false);
    }
    if (!lc.active && p) {
      this.fire('focus', {
        node: p
      });
    }
    lc.active = p;
    if (!p) {
      return this.fire('blur');
    }
    p.setAttribute('contenteditable', true);
    if (delay <= 250 || lc.drag) {
      sel = window.getSelection();
      if (sel.rangeCount) {
        r = sel.getRangeAt(0);
        if (!sel.isCollapsed && r.toString().length && ld$.parent(r.commonAncestorContainer, null, lc.active)) {
          range = r;
        }
      }
    }
    if (!range) {
      ld$.find(p, '[editable]').map(function(it){
        return it.setAttribute('contenteditable', false);
      });
      range = ldCaret.byPtr({
        node: p,
        x: x,
        y: y
      }).range;
    }
    n = range.endContainer;
    if (n && n.hasAttribute && n.hasAttribute('editable')) {
      range.setEndBefore(n);
    }
    return ldCaret.set(range);
  };
  /*
    fix contenteditable="false" + input/table/etc backspace issue in contenteditable.
  */
  backspaceFix = function(e){
    var target, sel, range, n, offset, prev;
    target = e.target;
    if (!(window.getSelection && e.which === 8)) {
      return;
    }
    sel = window.getSelection();
    if (!(sel.isCollapsed && sel.rangeCount)) {
      return;
    }
    range = sel.getRangeAt(sel.rangeCount - 1);
    if (range.commonAncestorContainer.nodeType === Element.TEXT_NODE && range.startOffset > 0) {
      return;
    }
    range = document.createRange();
    if (sel.anchorNode !== target) {
      range.selectNodeContents(target);
      range.setEndBefore(sel.anchorNode);
    } else if (sel.anchorOffset > 0) {
      range.setEnd(target, sel.anchorOffset);
    } else {
      return;
    }
    if (!range.endOffset) {
      n = range.endContainer;
      while (n && n.parentNode) {
        offset = Array.from(n.parentNode.childNodes).indexOf(n);
        if (offset > 0) {
          break;
        }
        n = n.parentNode;
      }
      if (!n) {
        return;
      }
      range.setStart(n.parentNode, offset - 1);
      range.setEnd(n.parentNode, offset);
    } else {
      range.setStart(target, range.endOffset - 1);
    }
    prev = range.cloneContents().lastChild;
    if (prev && prev.contentEditable === 'false') {
      range.deleteContents();
      return event.preventDefault();
    }
  };
  return window.contenteditable = ce;
});