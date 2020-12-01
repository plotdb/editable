/* integrated with ldCaret. dont need this anymore. */
caret-range = ({node, x, y, range}) ->
  if !range => range = document.createRange!
  if node.nodeType == Element.TEXT_NODE => return caret-range-text {node, x, y, range}
  min = null
  for i from 0 til node.childNodes.length =>
    r = caret-range {node: node.childNodes[i], x, y, range}
    if !min or r.min < min.min => min = r
  # min = null: this node is empty ( no childNodes ). select itself to get correct range box
  if !min =>
    p = node.parentNode
    c = Array.from(p.childNodes)
    range = document.createRange!
    range.setStart p, c.indexOf(node)
    range.setEnd p, c.indexOf(node) + 1
    box = range.getBoundingClientRect!
    tx = box.x + box.width / 2
    ty = box.y + box.height / 2
    dist = (tx - x) ** 2 + (ty - y) ** 2
    min = {min: dist, range: range}
  return min

caret-range-text = ({node, x, y}) ->
  range = document.createRange!
  for i from 0 til node.length + 1
    range.setStart node, i
    box = range.getBoundingClientRect!
    tx = box.x + box.width / 2
    ty = box.y + box.height / 2
    dist = (tx - x) ** 2 + (ty - y) ** 2
    if !(min?) or dist < min => [idx, min] = [i, dist]
  range.setStart node, idx
  range.setEnd node, idx
  return {min, range}

# rename to set-caret
set-caret = (range) ->
  n = range.startContainer
  o = range.startOffset
  # range not on text-node ( on element node ) 
  #   - we select the innermost first element 
  #   - we should also check recursively if it's editable
  if range.startContainer.nodeType != Element.TEXT_NODE =>
    _ = (n,o) ->
      if !n or !n.childNodes => return n
      ret = _(n.childNodes[o], 0)
      return if ret => that else n
    [n,o] = [_(n, o), 0]
  range.setStart n,o
  range.setEnd n,o
  select-range range

select-range = (range) ->
  sel = window.getSelection!
  sel.removeAllRanges!
  sel.addRange range
