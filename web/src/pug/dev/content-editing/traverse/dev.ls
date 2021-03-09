# promise based
if false =>

  ph = ld$.find('#ph', 0)
  ph-abs = ld$.find('#ph-abs', 0)
  lc = {node: null, idx: 0}
  delay = 1
  root = ld$.find('#root', 0)

  _proc = (box, payload) ->
    x = (box.x + box.width / 2)
    y = (box.y + box.height / 2)
    dist = Math.sqrt((payload.x - x) ** 2 + (payload.y - y) ** 2)
    if !(payload.dist?) or dist < payload.dist =>
      payload.dist = dist
      payload.box = box

  proc = (node, idx, payload) ->
    return if node.nodeType == 3 =>
      r = document.createRange!
      debounce 0
        .then -> 
          r.setStart node, idx
          r.setEnd node, idx
          box = r.getBoundingClientRect!
          ph-abs.style <<<
            left: "#{box.x}px"
            top: "#{box.y}px"
            height: "#{box.height}px"
          _proc box, payload
        .then -> debounce delay
        .then -> ph-abs.style <<< height: "0px"
    else if node.nodeType == 1 =>
      debounce 0
        .then ->
          if ph.parentNode => ph.parentNode.removeChild ph
          node.insertBefore ph, node.childNodes[idx]
        .then -> debounce delay
        .then ->
          console.log (box = ph.getBoundingClientRect!)
          _proc box, payload
        .then -> ph.parentNode.removeChild ph
    else Promise.resolve!

  handle = (root, payload) ->
    if root.nodeType == 1
      len = root.childNodes.length
      _ = (idx) ->
        if idx > len => return Promise.resolve!
        proc root, idx, payload
          .then ->
            if !root.childNodes[idx] => return
            handle root.childNodes[idx], payload
              .then -> _ idx + 1
      _ 0
    else if root.nodeType == 3 =>
      len = root.length
      _ = (idx) ->
        if idx >= len => return Promise.resolve!
        proc root, idx, payload
          .then -> _ idx + 1
      _ 1

    else return Promise.resolve!

  root.addEventListener \click, (e) ->
    payload = {x: e.clientX, y: e.clientY}
    handle root, payload
      .then ->
        console.log "matched: ", payload.box
        box = payload.box
        ph-abs.style <<<
          left: "#{box.x}px"
          top: "#{box.y}px"
          height: "#{box.height}px"


# use range
if false =>
  ph = ld$.find('#ph-abs', 0)
  ping = (r, n) ->
    debounce 500
      .then ->
        box = r.getBoundingClientRect!
        console.log n, box.x, box.y
        ph.style <<< do
          left: "#{box.x}px"
          top: "#{box.y}px"
          height: "#{box.height}px"

  worker = (n) ->
    r = document.createRange!
    r.setStart n, 0
    r.setEnd n, 1
    ping r, \a
      .then ->
        if n.nodeType == 1 and n.childNodes =>
          cs = Array.from(n.childNodes)
          _ = (idx) ->
            if !cs[idx] => return Promise.resolve!
            console.log ">", idx, cs.length, n
            worker cs[idx]
              .then ->
                r.setStart n, (idx + 1)
                #r.setEnd n, (idx + 2)
                tw = document.createTreeWalker cs[idx]
                nn = tw.nextNode!
                console.log cs[idx], nn
                if cs[idx + 2] => r.setEnd n, (idx + 2)
                else r.setEnd n, (idx + 1)
                ping r, \b
              .then -> _ idx + 1
          _ 0
        else
          _ = (idx) ->
            if idx >= n.length => return Promise.resolve!
            r.setStart n, idx + 1
            r.setEnd n, idx + 1
            ping r, \c
              .then -> _ idx + 1
          _ 0

      .then -> 

  worker ld$.find('#root', 0)

/* using treewalker */
if false =>
  ph = ld$.find('#ph-abs', 0)
  tw = document.createTreeWalker ld$.find('#root', 0), NodeFilter.SHOW_ALL

  lc = do
    cnode: tw.currentNode

  handler = setInterval (->
    console.log lc.cnode
    if lc.cnode =>
      if lc.cnode.getBoundingClientRect
        box = lc.cnode.getBoundingClientRect!
        ph.style <<< do
          left: "#{box.x}px"
          top: "#{box.y}px"
          height: "#{box.height}px"
      lc.cnode = tw.nextNode!
    else
      clearInterval handler
  ), 200

