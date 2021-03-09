
if true =>
  ph = ld$.find('#ph', 0)
  ph-abs = ld$.find('#ph-abs', 0)
  lc = {node: null, idx: 0}
  delay = 1
  root = ld$.find('#root', 0)
  tgt = ld$.find('#tgt', 0)

  _proc = (node, idx, box, payload) ->
    x = (box.x + box.width / 2)
    y = (box.y + box.height / 2)
    dist = Math.sqrt((payload.x - x) ** 2 + (payload.y - y) ** 2)
    if !(payload.dist?) or dist < payload.dist =>
      payload.dist = dist
      payload.box = box
      payload <<< {dist, box, node, idx}

  proc = (node, idx, payload) ->
    if node.nodeType == 3 =>
      r = document.createRange!
      r.setStart node, idx
      r.setEnd node, idx
      box = r.getBoundingClientRect!
      ph-abs.style <<<
        left: "#{box.x}px"
        top: "#{box.y}px"
        height: "#{box.height}px"
        opacity: 1
      _proc node, idx, box, payload
      ph-abs.style <<< height: "0px"
    else if node.nodeType == 1 =>
      if ph.parentNode => ph.parentNode.removeChild ph
      node.insertBefore ph, node.childNodes[idx]
      box = ph.getBoundingClientRect!
      _proc node, idx, box, payload
      ph.parentNode.removeChild ph

  handle = (root, payload) ->
    if root.nodeType == 1
      len = root.childNodes.length
      for idx from 0 to len 
        proc root, idx, payload
        if !root.childNodes[idx] => break
        handle root.childNodes[idx], payload
    else if root.nodeType == 3 =>
      len = root.length
      for idx from 1 til len
        proc root, idx, payload

  dragover = debounce 30, (e) ->
    payload = {x: e.clientX, y: e.clientY}
    handle root, payload
    box = payload.box
    ph-abs.style <<<
      left: "#{box.x}px"
      top: "#{box.y}px"
      height: "#{box.height}px"

  root.addEventListener \dragover, (e) ->
    e.preventDefault!
    lc.dragover = dragover e

  root.addEventListener \drop, (e) ->
    lc.dragover.cancel!
    lc.dragover = null
    e.preventDefault!
    payload = {x: e.clientX, y: e.clientY}
    handle root, payload
    box = payload.box
    ph-abs.style <<<
      left: "#{box.x}px"
      top: "#{box.y}px"
      height: "#{box.height}px"
      opacity: 0
    if ph.parentNode => ph.parentNode.removeChild ph
    {node,idx} = payload
    if ld$.parent(node, null, tgt) => return
    if node.nodeType == 1 =>
      ns = node.childNodes[idx]
      if ns == tgt => return
      if tgt.parentNode => tgt.parentNode.removeChild tgt
      node.insertBefore tgt, ns
    else if node.nodeType == 3 =>
      range = document.createRange!
      sel = window.getSelection!
      sel.removeAllRanges!
      sel.addRange range
      range.setStart node, idx
      range.setEnd node, idx
      range.deleteContents!
      if tgt.parentNode => tgt.parentNode.removeChild tgt
      range.insertNode tgt
      sel.removeAllRanges!
