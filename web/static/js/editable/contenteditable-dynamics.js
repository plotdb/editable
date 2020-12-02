var contenteditableDynamics, cd, setEditable;
contenteditableDynamics = cd = {
  events: {}
};
cd.events.mousedown = function(e){
  return cd.drag = false;
};
cd.events.mousemove = function(e){
  if (e.buttons === 1) {
    return cd.drag = true;
  }
};
cd.events.click = function(e){
  return setEditable.call(this, {
    target: e.target,
    x: e.clientX,
    y: e.clientY
  });
};
cd.setEditable = setEditable = function(arg$){
  var target, x, y, ct, delay, p, sel, r, range, n;
  target = arg$.target, x = arg$.x, y = arg$.y;
  ct = cd.ct;
  cd.ct = Date.now();
  delay = ct != null ? cd.ct - ct : 1000;
  p = ld$.parent(target, '[editable]');
  if (!ld$.parent(p, null, this.root)) {
    p = null;
  }
  if (this.activeLock && this.active !== p) {
    p = null;
  }
  if (this.active && this.active !== p) {
    this.active.setAttribute('contenteditable', false);
  }
  if (!this.active && p) {
    this.fire('focus', {
      node: p
    });
  }
  this.active = p;
  if (!p) {
    return this.fire('blur');
  }
  p.setAttribute('contenteditable', true);
  if (delay <= 250 || cd.drag) {
    sel = window.getSelection();
    if (sel.rangeCount) {
      r = sel.getRangeAt(0);
      if (!sel.isCollapsed && r.toString().length && ld$.parent(r.commonAncestorContainer, null, this.active)) {
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