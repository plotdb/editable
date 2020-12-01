/* integrated with ldCaret. dont need this anymore. */
var caretRange, caretRangeText, setCaret, selectRange;
caretRange = function(arg$){
  var node, x, y, range, min, i$, to$, i, r, p, c, box, tx, ty, dist;
  node = arg$.node, x = arg$.x, y = arg$.y, range = arg$.range;
  if (!range) {
    range = document.createRange();
  }
  if (node.nodeType === Element.TEXT_NODE) {
    return caretRangeText({
      node: node,
      x: x,
      y: y,
      range: range
    });
  }
  min = null;
  for (i$ = 0, to$ = node.childNodes.length; i$ < to$; ++i$) {
    i = i$;
    r = caretRange({
      node: node.childNodes[i],
      x: x,
      y: y,
      range: range
    });
    if (!min || r.min < min.min) {
      min = r;
    }
  }
  if (!min) {
    p = node.parentNode;
    c = Array.from(p.childNodes);
    range = document.createRange();
    range.setStart(p, c.indexOf(node));
    range.setEnd(p, c.indexOf(node) + 1);
    box = range.getBoundingClientRect();
    tx = box.x + box.width / 2;
    ty = box.y + box.height / 2;
    dist = Math.pow(tx - x, 2) + Math.pow(ty - y, 2);
    min = {
      min: dist,
      range: range
    };
  }
  return min;
};
caretRangeText = function(arg$){
  var node, x, y, range, i$, to$, i, box, tx, ty, dist, ref$, idx, min;
  node = arg$.node, x = arg$.x, y = arg$.y;
  range = document.createRange();
  for (i$ = 0, to$ = node.length + 1; i$ < to$; ++i$) {
    i = i$;
    range.setStart(node, i);
    box = range.getBoundingClientRect();
    tx = box.x + box.width / 2;
    ty = box.y + box.height / 2;
    dist = Math.pow(tx - x, 2) + Math.pow(ty - y, 2);
    if (!(typeof min != 'undefined' && min !== null) || dist < min) {
      ref$ = [i, dist], idx = ref$[0], min = ref$[1];
    }
  }
  range.setStart(node, idx);
  range.setEnd(node, idx);
  return {
    min: min,
    range: range
  };
};
setCaret = function(range){
  var n, o, _, ref$;
  n = range.startContainer;
  o = range.startOffset;
  if (range.startContainer.nodeType !== Element.TEXT_NODE) {
    _ = function(n, o){
      var ret, that;
      if (!n || !n.childNodes) {
        return n;
      }
      ret = _(n.childNodes[o], 0);
      return (that = ret) ? that : n;
    };
    ref$ = [_(n, o), 0], n = ref$[0], o = ref$[1];
  }
  range.setStart(n, o);
  range.setEnd(n, o);
  return selectRange(range);
};
selectRange = function(range){
  var sel;
  sel = window.getSelection();
  sel.removeAllRanges();
  return sel.addRange(range);
};