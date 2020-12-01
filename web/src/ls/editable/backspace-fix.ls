# TODO integrate with editable object
/*
  fix contenteditable="false" + input/table/etc backspace issue in contenteditable.
*/
document.addEventListener \keydown, (evt) ->
  target = evt.target
  # not backspace -> return
  if !(window.getSelection and evt.which == 8) => return
  sel = window.getSelection!
  # not collapsed selection -> return
  if !(sel.isCollapsed and sel.rangeCount) => return
  range = sel.getRangeAt sel.rangeCount - 1
  # deleting plain text -> return
  if range.commonAncestorContainer.nodeType == Element.TEXT_NODE and range.startOffset > 0 => return
  range = document.createRange!
  # char mode
  if sel.anchorNode != target => 
    range.selectNodeContents target
    range.setEndBefore sel.anchorNode
  else if sel.anchorOffset > 0
    range.setEnd target, sel.anchorOffset
  # reach beginning
  else return

  # somewhat endContainer on an empty object.
  # in order to find the next item to delete, we need to go up.
  if !range.endOffset =>
    n = range.endContainer
    while n and n.parentNode
      offset = Array.from(n.parentNode.childNodes).indexOf(n)
      if offset > 0 => break
      n = n.parentNode
    if !n => return
    range.setStart n.parentNode, offset - 1
    range.setEnd n.parentNode, offset
  else
    range.setStart target, range.endOffset - 1

  prev = range.cloneContents!lastChild
  if prev and prev.contentEditable == \false =>
    range.deleteContents!
    event.preventDefault!
