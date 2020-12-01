contenteditable-dynamics = cd = {events: {}}

cd.events.mousedown = (e) -> cd.drag = false
cd.events.mousemove = (e) -> if e.buttons == 1 => cd.drag = true

# clicking on some editable. it's possible that this is double / triple click or even a drag to select.
# if possible, focus on the editable and tell editor that we want to edit by returning true.
cd.events.click = (e) ->
  ct = cd.ct
  cd.ct = Date.now!
  delay = if ct? => (cd.ct - ct) else 1000
  p = ld$.parent(e.target, '[editable]')
  if !ld$.parent(p,null,@root) => return

  # we are already in editing mode. clicking on any other editable should not enable them.
  # TODO WIP
  #if editor.get-mode! == \edit => return true

  if @active and @active != p => @active.setAttribute \contenteditable, false
  @active = p
  if !p => return
  p.setAttribute \contenteditable, true

  # since we set caret manually, we have to take care of selection otherwise user wont be able to select text.
  # common behavior of clicking on editable
  #  - single click: set caret
  #  - 2nd click: extend selection to target end
  #  - 3rd click: extend selection to target start
  #  - drag: select certain range of content
  #  - shift-click: extend / shrink select start / end
  #  - shift-array: extend / shrink select start / end

  # use current selection to prepare range.
  # we only do this when -
  #  1. double/nth click - delay should <= 500
  #  2. click triggered by drag to select - cd.drag should be true
  if delay <= 250 or cd.drag =>
    sel = window.getSelection!
    if sel.rangeCount =>
      r = sel.getRangeAt 0
      # 2 criteria:
      #  1. it should be a selection (!collapsed and content length > 0), instead of a single point
      #    - sometimes a !collapsed range is from text end to next editable start. ( len = 0 ). just exclude it
      #      this happens when user double clicks outside text. 
      #  2. it should be inside our editor
      if !sel.isCollapsed and r.toString!length and
      ld$.parent(r.commonAncestorContainer, null, @active) => range = r

  if !range =>
    ld$.find(p, '[editable]').map -> it.setAttribute \contenteditable, false
    {range} = ldCaret.by-ptr {node: p, x: e.clientX, y: e.clientY}

  # sometimes selection from system default set end to next editable.
  # in this case, typing after selection won't work and character just disappear.
  # thus we just reset the end to before-the-end-container
  n = range.endContainer
  if n and n.hasAttribute and n.hasAttribute \editable => range.setEndBefore n

  ldCaret.set range

