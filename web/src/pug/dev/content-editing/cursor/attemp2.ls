# ←37, ↑38, →39, ↓40

insert-u200b = (obj) ->
  {c,i} = obj
  placeholder = document.createTextNode('x')
  c.insertBefore placeholder, c.childNodes[i]

ensure-u200b = (obj) ->
  {c,i} = obj
  if c.nodeType == 1 =>
    L = c.childNodes[i]
    R = c.childNodes[i - 1]
    if !L or !R or (L.nodeType == 1 and L.nodeType == 1) =>
      insert-u200b obj
      obj.i++
  else if c.nodeType == 3 => return

work = (obj) ->
  {c,i} = obj
  console.log "node type: ", c.nodeType, "i: ", i
  if c.nodeType == 3 =>
    if obj.i < obj.c.length - 1 => return obj.i++
    else if obj.i == obj.c.length - 1 =>
      i = (Array.from(obj.c.parentNode.childNodes).indexOf(obj.c) + 1)
      c = obj.c.parentNode
      console.log ">>>", c, i
      obj <<< {c, i}
    else if obj.i == obj.c.length =>
      console.log \here
      i = (Array.from(obj.c.parentNode.childNodes).indexOf(obj.c) + 1)
      c = obj.c.parentNode
      obj <<< {c, i}
      return work obj



root.addEventListener \keydown, (e) ->
  if !(e.keyCode in [37,39]) => return
  e.preventDefault!
  ret = ldCaret.get!
  obj = {c: ret.ne, i: ret.oe}
  work obj
  ret.ne = ret.ns = obj.c
  ret.oe = ret.os = obj.i
  console.log "ldcaret.set: ", ret
  ldCaret.set ret


