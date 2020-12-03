<-(->it!) _
# TODO integrate with editable object

/* sample code for getting prev node.
get-prev = (n) ->
  if !n.previousSibling => return n.parentNode
  n = n.previousSibling
  while true
    if !n.childNodes or !n.childNodes[* - 1] => break
    n = n.childNodes[* - 1]
  return n
*/

get-next = (n) ->
  if n.childNodes and n.childNodes.length => return n.childNodes.0
  if n.nextSibling => return that
  while true
    n = n.parentNode
    if !n => return null
    if n.nextSibling => return that

show-selected-nodes = (sel) ->
  range = sel.getRangeAt 0
  start = range.startContainer
  end = range.endContainer
  if start.nodeType != Element.TEXT_NODE => start = start.childNodes[range.startOffset]
  if end.nodeType != Element.TEXT_NODE => end = end.childNodes[range.endOffset]
  cur = start
  for i from 0 til 100
    cur = get-next(cur)
    if !cur or cur == end => break

pp = do
  events: do
    copy: (e) ->
      sel = document.getSelection!
      show-selected-nodes(sel)
      e.clipboardData.setData \text/plain, sel.toString!
      e.preventDefault!
    # intercept paste data and remove style
    paste: (e) ->
      data = e.clipboardData.getData(\text/plain)
      document.execCommand \insertText, false, data
      e.preventDefault!

  init: ->
    @mod.plainpase = {}
    [{k,v} for k,v of pp.events].map ({k,v}) ~> document.addEventListener k, (e) ~> v.call @, e

window.editable.{}mod.register \plainpaste, pp
