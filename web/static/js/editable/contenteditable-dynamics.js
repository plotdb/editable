var contenteditableDynamics, cd;
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
  var ct, delay, p, sel, r, range, n;
  ct = cd.ct;
  cd.ct = Date.now();
  delay = ct != null ? cd.ct - ct : 1000;
  p = ld$.parent(e.target, '[editable]');
  if (!ld$.parent(p, null, this.root)) {
    return;
  }
  if (this.active && this.active !== p) {
    this.active.setAttribute('contenteditable', false);
  }
  this.active = p;
  if (!p) {
    return;
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
      x: e.clientX,
      y: e.clientY
    }).range;
  }
  n = range.endContainer;
  if (n && n.hasAttribute && n.hasAttribute('editable')) {
    range.setEndBefore(n);
  }
  return ldCaret.set(range);
};