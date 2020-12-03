<-(->it!) _

hub = do
  events: do
    # DOM might change, so we reinit drag/drop handler each time when necessary.
    # dragger obj will check if the corresponding node isn't inited and belongs to it.
    mousedown: (e) ->
      n = e.target
      while n and !(n.hasAttribute and n.hasAttribute \draggable) => n = n.parentNode
      if n => n.setAttribute \draggable, true
    dragstart: (e) ->
      d = @mod.dragger
      src = e.target
      e.dataTransfer.setData(\application/json, JSON.stringify({}))
      e.dataTransfer.setDragImage(hub.ghost,10,10)
      d.set-drag true
      e.stopPropagation!
    dragover: (e) ->
      d = @mod.dragger
      ret = ldCaret.by-ptr {node: document.body, x: e.clientX, y: e.clientY}
      if !d.contains(ret.range.startContainer) => return
      d.render ret.range
      e.preventDefault!
    drop: (e) ->
      [n,d] = [e.target, @mod.dragger]
      if !d.contains(n) => return
      if (json = e.dataTransfer.getData \application/json) => data = JSON.parse json
      d.render!
      d.set-drag false
      e.preventDefault!


  ghost: (new Image!) <<< src: "data:image/svg+xml," + encodeURIComponent("""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="15" viewBox="0 0 20 15">
    <rect x="0" y="0" width="20" height="15" fill="rgba(0,0,0,.5)"/>
    </svg>""")
  init: -> @mod.dragger = new dragger {root:@root} 

dragger = (opt={}) ->
  @opt = opt
  root = opt.root
  @root = root = if typeof(root) == \string => document.querySelector(root) else if root => root else null
  @ <<< do
    dragging: false
    caret: null
    src: null
  @caret = {box: null, range: null}
  @evt-handler = {}
  @init!
  @

dragger.prototype = Object.create(Object.prototype) <<< do
  init: ->
    @caret.box = document.createElement("div")
    @caret.box.style <<< do
      position: \fixed
      left: 0
      top: 0
      display: \none
      border: '2px solid #f0f'
      pointerEvents: \none
      transition: "opacity .15s ease-in-out"
      animation: "blink .4s linear infinite"
    document.body.appendChild @caret.box
  contains: (n) -> @root.contains n
  set-drag: -> @dragging = it
  render: (r) ->
    if !r => return @caret.box.style <<< display: \none
    box = r.getBoundingClientRect!
    @caret.box.style <<< do
      left: "#{box.x}px"
      top: "#{box.y}px"
      height: "#{box.height}px"
      width: \2px
      position: \absolute
      border: "2px solid \#f00"
      display: \block

window.editable.{}mod.register \dragger, hub
