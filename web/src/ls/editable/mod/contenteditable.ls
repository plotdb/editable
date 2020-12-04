<-(->it!) _

# contenteditable handles nested editable and take care of selection, clicking behavior.
# function called by editable using apply, thus @ is editable object.

contenteditable = ce = do
  events: do
    # for detecting if user is dragging ( for text selection )
    mousedown: (e) -> @mod.contenteditable.drag = false
    mousemove: (e) -> if e.buttons == 1 => @mod.contenteditable.drag = true

    # fix contenteditable="false" + input/table/etc backspace issue in contenteditable.
    keydown: (e) -> backspace-fix.call @, e

    # activate editable tag.
    click: (e) -> set-editable.call @, {target: e.target, x: e.clientX, y: e.clientY}

    # escape / de-activate tag. TODO might be an issue if user is typing with an IME?
    keyup: (e) -> if e.which == 27 => ce.set-editable.call @, {target: null}
  init: ->
    @mod.contenteditable = {}
    #[{k,v} for k,v of ce.events].map ({k,v}) ~> document.addEventListener k, (e) ~> v.call @, e

# clicking on some editable. it's possible that this is double / triple click or even a drag to select.
# if possible, focus on the editable and tell editor that we want to edit by returning true.
contenteditable.set-editable = set-editable = ({target, x, y}) ->
  lc = @mod.contenteditable
  # calculate elapsed time between two adjacnet clicks
  ct = lc.ct
  lc.ct = Date.now!
  delay = if ct? => (lc.ct - ct) else 1000
  p = ld$.parent(target, '[editable]')
  if !ld$.parent(p,null,@root) => p = null
  # set lock to true to block editable change.
  # however, if p = @active, we allow it to go through so we can handle selection.
  if lc.lock and lc.active != p => p = null

  if lc.active and lc.active != p => lc.active.setAttribute \contenteditable, false
  if !lc.active and p => @fire \focus, {node: p}
  lc.active = p
  if !p => return @fire \blur
  p.setAttribute \contenteditable, true

  # since we set caret manually, we have to take care of selection otherwise user wont be able to select text.
  # common behavior of clicking on editable
  #  - single click: set caret
  #  - 2nd click: extend selection to target end
  #  - 3rd click: extend selection to target start
  #  - drag: select certain range of content
  #  - shift-click: extend / shrink select start / end <-- TODO
  #  - shift-arrow: extend / shrink select start / end

  # use current selection to prepare range.
  # we only do this when -
  #  1. double/nth click - delay should <= 500
  #  2. click triggered by drag to select - editable.drag should be true
  if delay <= 250 or lc.drag =>
    sel = window.getSelection!
    if sel.rangeCount =>
      r = sel.getRangeAt 0
      # 2 criteria:
      #  1. it should be a selection (!collapsed and content length > 0), instead of a single point
      #    - sometimes a !collapsed range is from text end to next editable start. ( len = 0 ). just exclude it
      #      this happens when user double clicks outside text. 
      #  2. it should be inside our editor
      if !sel.isCollapsed and r.toString!length and
      ld$.parent(r.commonAncestorContainer, null, lc.active) => range = r

  if !range =>
    ld$.find(p, '[editable]').map -> it.setAttribute \contenteditable, false
    {range} = ldCaret.by-ptr {node: p, x: x, y: y}

  # sometimes selection from system default set end to next editable.
  # in this case, typing after selection won't work and character just disappear.
  # thus we just reset the end to before-the-end-container
  n = range.endContainer
  if n and n.hasAttribute and n.hasAttribute \editable => range.setEndBefore n

  ldCaret.set range

/*
  fix contenteditable="false" + input/table/etc backspace issue in contenteditable.
*/
backspace-fix = (e) ->
  target = e.target
  # not backspace -> return
  if !(window.getSelection and e.which == 8) => return
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


window.editable.{}mod.register \contenteditable, ce
