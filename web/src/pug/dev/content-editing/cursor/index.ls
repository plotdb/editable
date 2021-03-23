# ←37, ↑38, →39, ↓40


# move cursor from specific position to next position.
# obj:
#  n: container node 
#  i: index of child where cursor is before
#  d: direction ( false: previous, true: next )
lc = {obj: null}
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
  lc.obj = {n, i, d, ph: if ph => true else false}


ph-abs = ld$.find '#ph-abs', 0

simple.addEventListener \input, (e) -> console.log 'input'
simple.addEventListener \change, (e) -> console.log 'change'

makeph = -> document.createTextNode "\u200b"

document.body.addEventListener \keydown, (e) ->
  if (e.keyCode in [37,39]) => return
  if !lc.obj => return
  {n,i,d,ph} = lc.obj
  if !ph => return
  lc.obj.ph = false
  lc.ph1 = makeph!
  lc.ph2 = makeph!
  n.insertBefore lc.ph1, n.childNodes[i]
  n.insertBefore lc.ph2, n.childNodes[i + 1]
  range = document.createRange!
    ..setStart n, i + 1
    ..setEnd n, i + 1
  ldCaret.set range


  
document.body.addEventListener \input, (e) ->
  if !lc.obj => return
  if (e.keyCode in [37,39]) => return
  keyup e

keyup = (e) ->
  [lc.ph1, lc.ph2].filter(->it and it.parentNode).map (n) ->
    n.textContent = n.textContent.replace /\u200b/g, ''
    if n.textContent.length < 1 => n.parentNode.removeChild n
  ph1 = (lc.ph1 and lc.ph1.parentNode)
  ph2 = (lc.ph2 and lc.ph2.parentNode)
  delta = if ph1 and ph2 => 2 else if ph1 or ph2 => 1 else 0
  lc.ph1 = lc.ph2 = null
  {n,i,d,ph} = lc.obj
  range = document.createRange!
    ..setStart n, i + delta
    ..setEnd n, i + delta
  ldCaret.set range
  lc.obj.i = i + delta

/*
document.body.addEventListener \keydown, (e) ->
  if (e.keyCode in [37,39]) => return
  if !lc.obj => return
  {n,i,d} = lc.obj
  if n.nodeType == 3 => return
  lc.ph = document.createTextNode '\u200b'
  n.insertBefore lc.ph, n.childNodes[i]
  range = document.createRange!
    ..setStart n, i + 1
    ..setEnd n, i + 1 #(i + if lc.ph => 1 else 0)
  ldCaret.set range
document.body.addEventListener \keyup, (e) ->
  if !lc.ph => return
  lc.ph.textContent = lc.ph.textContent.replace /\u200b/g, ''
  if lc.ph.textContent.length < 1 => lc.ph.parentNode.removeChild lc.ph
  lc.ph = null
  lc.obj = null
*/

document.body.addEventListener \keydown, (e) ->
  if !(e.keyCode in [37,39]) => return
  e.preventDefault!
  move {inc: e.keyCode == 39}

