<-(->it!) _

mod = do
  events: do
    mouseover: (e) ->
      if !((n = e.target) and e.target.hasAttribute) => return
      if !n.hasAttribute(\resizable) or n.getAttribute(\resizable) == \false => return
      if n._itr => return
      n.style.touchAction = \none
      n._itr = interact(n).resizable mod.config.resizable
      # draggable != true -> resize mode. in this case we don't want to focus after resize done.
      # stop propagation in clicking handler can do this trick.
      n.addEventListener \click, (e) ->
        if e.target.getAttribute(\draggable) == \true => return
        e.stopPropagation!
    mousedown: (e) ->
      if !((n = e.target) and n._itr and n.getBoundingClientRect) => return
      box = n.getBoundingClientRect!
      [x,y] = [e.clientX, e.clientY]
      min = Math.min.apply(
        Math, [box.x - x, box.y - y, box.x + box.width - x, box.y + box.height - y].map(-> Math.abs(it))
      )
      n.setAttribute \draggable, (if min >= 20 => \true else \false)
  config: resizable:
    edges: {top: true, left: true, bottom: true, right: true}
    listeners: 
      move: (e) ->
        d = e.deltaRect
        nodes = [e.target,null,null]
        if d.left => nodes.1 = nodes.0.previousSibling or nodes.0.nextSibling
        if d.right => nodes.2 = nodes.0.nextSibling or nodes.0.previousSibling
        nodes = nodes.map -> if !(it and it.getBoundingClientRect) => null else it
        boxes = nodes.map -> if !it => null else it.getBoundingClientRect!
        nodes.map (d,i) -> if d and !d.w => d.w = boxes[i].width
        display = getComputedStyle(nodes.0).display
        if /inline/.exec(display) =>
          if d.left =>
            dw = d.left
            nodes.0.w = nodes.0.w - dw
            nodes.0.style <<< { width: "#{boxes.0.width - dw}px" }
          else if d.right =>
            dw = d.right
            nodes.0.w = nodes.0.w + dw
            nodes.0.style <<< { width: "#{nodes.0.w}px" }
          else
            nodes.0.style <<< { height: "#{e.rect.height}px" }
        else
          if nodes.2 =>
            dw = d.right
            nodes.0.w = nodes.0.w + dw
            nodes.2.w = nodes.2.w - dw
            nodes.0.style <<< { width: "#{nodes.0.w}px" }
            nodes.2.style <<< { width: "#{nodes.2.w}px" }
          if nodes.1 =>
            dw = d.left
            nodes.0.w = nodes.0.w - dw
            nodes.1.w = nodes.1.w + dw
            nodes.0.style <<< { width: "#{boxes.0.width - dw}px" }
            nodes.1.style <<< { width: "#{boxes.1.width + dw}px" }
          if !(nodes.1 and nodes.2) =>
            nodes.0.style <<< { height: "#{e.rect.height}px" }

  init: ->


window.editable.{}mod.register \resize, mod

