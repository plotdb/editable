(function(it){
  return it();
})(function(){
  var mod, ref$;
  mod = {
    contextmenu: {
      name: 'resize',
      list: {
        name: 'hello world'
      }
    },
    events: {
      mouseup: function(e){
        var n, ref$;
        if (!((n = e.target) && e.target.hasAttribute)) {
          return;
        }
        if (!n.hasAttribute('resizable') || n.getAttribute('resizable') === 'false') {
          return;
        }
        return ref$ = n.style, ref$.overflow = "", ref$.resize = "", ref$;
      },
      mouseover: function(e){
        var n, dir, ref$;
        if (!((n = e.target) && e.target.hasAttribute)) {
          return;
        }
        if (!n.hasAttribute('resizable') || n.getAttribute('resizable') === 'false') {
          return;
        }
        dir = getComputedStyle(n).display === 'block' && !((ref$ = getComputedStyle(n.parentNode).display) === 'flex' || ref$ === 'grid') ? 'vertical' : 'both';
        return ref$ = n.style, ref$.overflow = "hidden", ref$.resize = dir, ref$;
      }
      /*
      mouseover: (e) ->
        if !((n = e.target) and e.target.hasAttribute) => return
        if !n.hasAttribute(\resizable) or n.getAttribute(\resizable) == \false => return
        if n._itr => return
        n.style.touchAction = \none
        is-inline = /inline/.exec(getComputedStyle(n).display)
        edges = {top: !is-inline, left: !is-inline, bottom: true, right: true}
        n._itr = interact(n).resizable(mod.config.resizable <<< {edges})
      
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
      */
    }
    /*
    config:
      resizable:
        edges: {top: false, left: false, bottom: true, right: true}
        listeners:
          move: (e) ->
            draggable = mod.config.resizable.edges
            lock-ratio =  e.shiftKey
            d = e.deltaRect
            nodes = [e.target,null,null]
            if d.left or d.top => nodes.1 = nodes.0.previousSibling or nodes.0.nextSibling
            if d.right or d.bottom => nodes.2 = nodes.0.nextSibling or nodes.0.previousSibling
            nodes = nodes.map -> if !(it and it.getBoundingClientRect) => null else it
            boxes = nodes.map -> if !it => null else it.getBoundingClientRect!
            nodes.map (d,i) ->
              if d and !d.w => d.w = boxes[i].width
              if d and !d.h => d.h = boxes[i].height
            display = getComputedStyle(nodes.0).display
            ps = getComputedStyle(nodes.0.parentNode)
            flex = ps.display
            flex-dir = ps.flexDirection
            flex-justify = ps.justifyContent
            if /inline/.exec(display) =>
              [dw, dh, dir] = [0, 0, 0]
              if d.left => [dw,dir] = [-d.left, dir + 1]
              if d.right => [dw,dir] = [d.right, dir + 4]
              if d.top => [dh, dir] = [-d.top, dir + 2]
              if d.bottom => [dh, dir] = [d.bottom, dir + 8]
              if lock-ratio =>
                favor-w = if dir .&. 5 and dir .&. 10 =>
                  if dw > dh => true else false
                else if dir .&. 5 => true else false
                if favor-w => dh = dw / nodes.0.w * nodes.0.h
                else dw = dh / nodes.0.h * nodes.0.w
    
              nodes.0.w = nodes.0.w + dw
              nodes.0.h = nodes.0.h + dh
              nodes.0.style <<< { width: "#{nodes.0.w}px" }
              nodes.0.style <<< { height: "#{nodes.0.h}px" }
    
            else if /flex/.exec(flex)
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
    
            else # ignore
    */,
    init: function(){}
  };
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('resize', mod);
});