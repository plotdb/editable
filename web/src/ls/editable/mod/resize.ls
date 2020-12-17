<-(->it!) _

mod = do
  events: do
    mouseover: (e) ->
      if !((n = e.target) and e.target.hasAttribute) => return
      if !n.hasAttribute(\resizable) or n.getAttribute(\resizable) == \false => return
      if n._itr => return
      n._itr = interact(n).resizable mod.config.resizable
    mousedown: (e) ->
      if !((n = e.target) and n._itr) => return
      n.setAttribute \draggable, false
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
        nodes.filter(->it).map ->
          b = it.getBoundingClientRect!
          it.innerText = b.width


  init: ->


window.editable.{}mod.register \resize, mod

/*
ld$.find '.flex-grow-1'
  .map -> [it, it.getBoundingClientRect!width]
  .map -> it.0.style.width = "#{it.1}px"
obj = do
  edges: {top: true, left: true, bottom: true, right: true}
  listeners: 
    move: (e) ->
      if true =>
        d = e.deltaRect
        nodes = [e.target,null,null]
        if d.left => nodes.1 = nodes.0.previousSibling or nodes.0.nextSibling
        if d.right => nodes.2 = nodes.0.nextSibling or nodes.0.previousSibling
        boxes = nodes.map -> if !it => null else it.getBoundingClientRect!
        nodes.map (d,i) -> if d and !d.w => d.w = boxes[i].width
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
        nodes.filter(->it).map ->
          b = it.getBoundingClientRect!
          it.innerText = b.width
      else
        w = e.rect.width
        h = e.rect.height
        n1 = e.target
        b1 = n1.getBoundingClientRect!
        n2 = e.target.nextSibling
        b2 = n2.getBoundingClientRect!
        dw = w - b1.width 
        dh = h - b1.height 
        n1.style <<< do
          width: "#{b1.width + dw}px", height: "#{b1.height + dh}px"
        n2.style <<< do
          width: "#{b2.width - dw}px", height: "#{b2.height}px"

ld$.find('.flex-grow-1').map -> interact(it).resizable obj
*/
