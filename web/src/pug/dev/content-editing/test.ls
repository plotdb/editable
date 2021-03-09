ghost = new Image!
ghost.src = "data:image/svg+xml," + encodeURIComponent("""
<svg xmlns="http://www.w3.org/2000/svg" width="20" height="15" viewBox="0 0 20 15">
  <rect x="0" y="0" width="20" height="15" fill="rgba(0,0,0,.5)"/>
</svg>
""")

ph = ld$.find \#placeholder, 0
ph.parentNode.removeChild ph
btn.addEventListener \dragstart, (e) -> e.dataTransfer.setDragImage(ghost,10,10)

content.addEventListener \dragover, (e) ->

content.addEventListener \drop, (e) ->


/*
content.addEventListener \dragover, (e) ->
  e.preventDefault!
  lc.count = lc.count + 1
  if (lc.count % 10) => return
  # always preventDefault even if not in range, otherwise drop won't be triggered.
  #d = @mod.dragger
  #ret = ldCaret.by-ptr {node: content, x: e.clientX, y: e.clientY, method: \vertical}
  ret = ldCaret.by-ptr {node: e.target, x: e.clientX, y: e.clientY, method: \vertical}
  console.log ret.range.startContainer, ret.range.startOffset
  insert ret.range.startContainer, ret.range.startOffset, ph
  #if !d.contains(ret.range.startContainer) => return
  #d.render({} <<< ret{range} <<< {mode})
content.addEventListener \drop, (e) ->
  e.preventDefault!
  n = document.createTextNode "[]"
  ph.parentNode.insertBefore n, ph
  ph.parentNode.removeChild ph
lc = {count: 0}
insert = (ta, so, n) ->
  lc <<< {ta, so}
  if ta == n => return
  if ta.nodeType == Element.TEXT_NODE
    if n.parentNode => n.parentNode.removeChild n
    text = ta.textContent
    [
      document.createTextNode text.substring(0,so)
      n
      document.createTextNode text.substring(so)
    ].map -> ta.parentNode.insertBefore it, ta
    ta.parentNode.removeChild ta
  else
    m = ta.childNodes[so]
    ta.insertBefore n, m.nextSibling
*/
