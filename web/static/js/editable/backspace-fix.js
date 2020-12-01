/*
  fix contenteditable="false" + input/table/etc backspace issue in contenteditable.
*/
document.addEventListener('keydown', function(evt){
  var target, sel, range, n, offset, prev;
  target = evt.target;
  if (!(window.getSelection && evt.which === 8)) {
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
});