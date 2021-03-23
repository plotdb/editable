# ←37, ↑38, →39, ↓40


# move cursor from specific position to next position.
# obj:
#  n: container node 
#  i: index of child where cursor is before
#  d: direction ( false: previous, true: next )
move = (opt={}) ->
  _ = (obj) ->
    {n,i,d} = obj
    if d =>
      if n.nodeType == 1 =>
        if n.childNodes[i] => obj <<< {n: n.childNodes[i], i: 0}
        else obj <<< {n: n.parentNode, i: Array.from(n.parentNode.childNodes).indexOf(n) + 1}
      else if n.nodeType == 3 =>
        if i < n.length => obj.i = i = i + 1
        if i == n.length => obj <<< {n: n.parentNode, i: Array.from(n.parentNode.childNodes).indexOf(n) + 1}
    else =>
      if n.nodeType == 1 =>
        if n.childNodes[i - 1] =>
          nn = n.childNodes[i - 1]
          obj <<< {n: nn, i: nn.length or nn.childNodes.length}
        else obj <<< {n: n.parentNode, i: Array.from(n.parentNode.childNodes).indexOf(n)}
      else if n.nodeType == 3 =>
        if i > 0 => obj.i = i = i - 1
        if i == 0 => obj <<< {n: n.parentNode, i: Array.from(n.parentNode.childNodes).indexOf(n)}
    return obj
  ret = ldCaret.get!
  {n,i,d} = _({n: ret.ne, i: ret.oe, d: opt.inc})
  if n.nodeType == 3 => if i == 0 or i == n.length => {n,i,d} = _({n,i,d})
  if n.nodeType == 1 =>
    ph = document.createTextNode '\u200b'
    n.insertBefore ph, n.childNodes[i]
  range = document.createRange!
    ..setStart n, i
    ..setEnd n, (i + if ph => 1 else 0)
  box = range.getBoundingClientRect!
  ph-abs.style <<< 
    left: "#{box.x}px"
    top: "#{box.y}px"
  if ph => n.removeChild ph
  ldCaret.set range


ph-abs = ld$.find '#ph-abs', 0

document.body.addEventListener \keydown, (e) ->
  if !(e.keyCode in [37,39]) => return
  e.preventDefault!
  move {inc: e.keyCode == 39}

