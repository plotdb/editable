# ←37, ↑38, →39, ↓40

work = (obj) ->
  console.log "working..."
  {n,i,d} = obj
  if d =>
    if n.nodeType == 1 =>
      if n.childNodes[i] =>
        nobj = {n: n.childNodes[i], i: 0}
        obj <<< nobj
      else
        nobj = {n: n.parentNode, i: Array.from(n.parentNode.childNodes).indexOf(n) + 1}
        obj <<< nobj
    else if n.nodeType == 3 =>
      if i < n.length => obj.i++
      if obj.i == n.length =>
        nobj = {n: n.parentNode, i: Array.from(n.parentNode.childNodes).indexOf(n) + 1}
        obj <<< nobj
  else =>
    if n.nodeType == 1 =>
      if n.childNodes[i - 1] =>
        nn = n.childNodes[i - 1]
        nobj = {n: nn, i: nn.length or nn.childNodes.length}
        obj <<< nobj
      else
        nobj = {n: n.parentNode, i: Array.from(n.parentNode.childNodes).indexOf(n)}
        obj <<< nobj
    else if n.nodeType == 3 =>
      if i > 0 => obj.i--
      if obj.i == 0 =>
        nobj = {n: n.parentNode, i: Array.from(n.parentNode.childNodes).indexOf(n)}
        obj <<< nobj


#ld$.find '[contenteditable]' .map -> it.setAttribute \contenteditable, false

lc = {obj: null}
ph-abs = ld$.find '#ph-abs', 0
document.body.addEventListener \keydown, (e) ->
  if (e.keyCode in [37,39]) => return
  ret = ldCaret.get!
  if !lc.obj =>
    lc.obj = {n: ret.ne, i: ret.oe}
    console.log "lc.obj:", lc.obj
  {n,i} = lc.obj
  if !n => return
  if n.nodeType == 1 =>
    lc.ph = document.createTextNode '\u200b'
    n.insertBefore lc.ph, n.childNodes[i]
    i++

  ret.ne = ret.ns = n
  ret.oe = ret.os = i
  console.log "!ldcaret.set: ", ret
  ldCaret.set ret
  debounce 0 .then ->
    inc = false
    if lc.ph =>
      ret = ldCaret.get!
      if lc.ph.textContent == '\u200b' =>
        inc = true
        lc.ph.parentNode.removeChild lc.ph
      else
        if /\u200b/g.exec(lc.ph.textContent) => ret.os = ret.oe = ret.oe - 1
        lc.ph.textContent = lc.ph.textContent.replace /\u200b/g, ''
      str = lc.ph.textContent
      console.log "!ldcaret.set(2): ", ret
      #for i from 0 til str.length => console.log str.charCodeAt i
      lc.ph = null
      #if inc => ret.oe = ret.os = i - 1
      ldCaret.set ret

  lc.obj = null

document.body.addEventListener \keydown, (e) ->
  if !(e.keyCode in [37,39]) => return
  if lc.ph and lc.ph.parentNode =>
    lc.ph.parentNode.removeChild lc.ph
    lc.ph = null
  e.preventDefault!
  if !lc.obj => 
    ret = ldCaret.get!
    console.log ret
    lc.obj = {n: ret.ne, i: ret.oe}
  lc.obj.d = (e.keyCode == 39)
  work lc.obj
  console.log "node type: ", lc.obj.n.nodeType
  if lc.obj.n.nodeType == 3 =>
    console.log \hit
    if lc.obj.i == 0 or lc.obj.i == lc.obj.n.length => work lc.obj
  if lc.obj.n.nodeType == 1 =>
    {n,i} = lc.obj
    lc.ph = document.createTextNode '\u200b'
    n.insertBefore lc.ph, n.childNodes[i]

    range = document.createRange!
    range.setStart lc.obj.n, lc.obj.i
    range.setEnd lc.obj.n, lc.obj.i + 1
    ret = range.getBoundingClientRect!
    ph-abs.style <<< 
      left: "#{ret.x}px"
      top: "#{ret.y}px"
    n.removeChild lc.ph
    lc.ph = null

  else
    range = document.createRange!
    range.setStart lc.obj.n, lc.obj.i
    range.setEnd lc.obj.n, lc.obj.i
    ret = range.getBoundingClientRect!
    ph-abs.style <<< 
      left: "#{ret.x}px"
      top: "#{ret.y}px"

  ldCaret.set range
  console.log "set: ", lc.obj
