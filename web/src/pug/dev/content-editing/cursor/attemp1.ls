ph = ->
  span = document.createElement('span')
  span.setAttribute \placeholder, \true
  span.appendChild document.createTextNode('x') # u+200b
  #span.appendChild document.createTextNode('\u200b') # u+200b
  return span

append-u200b = (obj) ->
  {c,i} = obj
  placeholder = document.createTextNode('x')
  c.insertBefore placeholder, c.childNodes[i]

ensure-u200b = (obj) ->
  {c,i} = obj
  if c.nodeType == 1 =>
    L = c.childNodes[i]
    R = c.childNodes[i - 1]
    if !L or !R or (L.nodeType == 1 and L.nodeType == 1) => append-u200b obj
  else if c.nodeType == 3 => return





work = (obj) ->
  console.log "pre-work: ", obj
  if obj.c.nodeType == 1 =>
    if (d = obj.c.childNodes[obj.i]) => obj <<< {c: d, i: if d.nodeType == 3 => 1 else 0}
    else
      i = (Array.from(obj.c.parentNode.childNodes).indexOf(obj.c) + 1)
      c = obj.c.parentNode
      obj <<< {c, i}
  else if obj.c.nodeType == 3 =>
    if obj.i < obj.c.length - 1 => return obj.i++
    else if obj.i == obj.c.length - 1 =>
      i = (Array.from(obj.c.parentNode.childNodes).indexOf(obj.c) + 1)
      c = obj.c.parentNode
      obj <<< {c, i}
    else if obj.i == obj.c.length =>
      i = (Array.from(obj.c.parentNode.childNodes).indexOf(obj.c) + 1)
      c = obj.c.parentNode
      obj <<< {c, i}
      return work obj

  if obj.c.nodeType == 1 =>
    console.log \here, obj
    if obj.i == 0 =>
      console.log ">>>", \here
      c = obj.c.childNodes.0
      if (!c.getAttribute or !c.getAttribute(\placeholder)) => obj.c.insertBefore ph!, c
      obj.i = 1
      return
    console.log obj.c, obj.i
    c1 = obj.c.childNodes[obj.i - 1]
    c2 = obj.c.childNodes[obj.i]
    if c1.nodeType == 1 and c2.nodeType == 1 =>
      console.log ">>>", c1.getAttribute, c2.getAttribute(\placeholde)
      if (!c2.getAttribute or !c2.getAttribute(\placeholder)) and
        (!c1.getAttribute or !c1.getAttribute(\placeholder))
        => obj.c.insertBefore ph!, c2
      obj.i = obj.i + 1
    else if c1.nodeType == 1 and c2.nodeType == 3 =>
      obj.c = c2
      obj.i = 1


root.addEventListener \keydown, (e) ->
  if !(e.keyCode in [37,39]) => return
  ret = ldCaret.get!
  if e.keyCode == 37 and ret.os > 0 =>
    return
    ret.oe = ret.os = ret.os - 1
    ldCaret.set ret
  else if e.keyCode == 39 =>
    e.preventDefault!
    obj = {c: ret.ne, i: ret.oe}
    work obj
    ret.ne = ret.ns = obj.c
    ret.oe = ret.os = obj.i
    console.log "ldcaret.set: ", ret
    ldCaret.set ret


