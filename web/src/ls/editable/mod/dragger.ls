<-(->it!) _


# we might have dragover from outside world ( like, block manager )
hub = do
  events: do
    # DOM might change, so we reinit drag/drop handler each time when necessary.
    # dragger obj will check if the corresponding node isn't inited and belongs to it.
    mousedown: (e) ->
      if !@mod.dragger.contains(e.target) => return
      n = e.target
      while n and !(n.hasAttribute and n.hasAttribute \draggable) => n = n.parentNode
      if n => n.setAttribute \draggable, true
    dragstart: (e) ->
      d = @mod.dragger
      d.src = e.target
      e.dataTransfer.setData(\application/json, JSON.stringify({}))
      e.dataTransfer.setDragImage(hub.ghost,10,10)
      d.set-drag true
      e.stopPropagation!

    dragover: (e) ->
      # always preventDefault even if not in range, otherwise drop won't be triggered.
      e.preventDefault!
      d = @mod.dragger
      ret = ldCaret.by-ptr {node: @root, x: e.clientX, y: e.clientY, method: \euclidean}
      if !d.contains(ret.range.startContainer) => return
      d.render ret{range}
    drop: (e) ->
      [n,d] = [e.target, @mod.dragger]
      e.preventDefault!
      d.drop {evt: e}

  ghost: (new Image!) <<< src: "data:image/svg+xml," + encodeURIComponent("""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="15" viewBox="0 0 20 15">
    <rect x="0" y="0" width="20" height="15" fill="rgba(0,0,0,.5)"/>
    </svg>""")
  init: -> @mod.dragger = new dragger {root: @root, editable: @}

dragger = (opt={}) ->
  @editable = opt.editable
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
    @caret.box.classList.add \mod-dragger-caret
    document.body.appendChild @caret.box
  contains: (n) -> @root.contains n
  set-drag: -> @dragging = it
  typematch: ({n,p}) ->
    if !(n and p) => return 0
    type = 0
    display = if n => getComputedStyle(n).display
    # block
    if p.hasAttribute(\hostable) and !/inline/.exec(display) => type += 1
    # inline-block
    if p.hasAttribute(\editable) and p.getAttribute(\editable) != \false and /inline/.exec(display) => type += 2
    return type

  render: (opt={}) ->
    range = opt.range
    if !range => return @caret.box.style <<< display: \none
    p = ld$.parent range.startContainer, "[hostable],[editable]:not([editable=false])", @root
    insertable = @typematch {p, n: @src}

    box = range.getBoundingClientRect!
    @caret.range = range
    @caret.box.style <<< do
      left: "#{box.x}px"
      top: "#{box.y}px"
      height: "#{box.height}px"
      display: \block
      opacity: if insertable => 1 else 0.4
      filter: if insertable => '' else "saturate(0)"

  drop: ({evt}) ->
    range = @caret.range
    # always render(null) to clear since we might have already rendered before and not yet clear it.
    @render!
    if !(range and @root.contains(evt.target)) => return
    p = ld$.parent range.startContainer, "[hostable],[editable]:not([editable=false])", @root
    if !p => return

    sc = range.startContainer
    so = range.startOffset
    ta = if sc.nodeType == Element.TEXT_NODE => sc else sc.childNodes[so]
    n = @src

    if !n =>
      # not inner drag - check data. any better way?
      data = if (json = evt.dataTransfer.getData \application/json) => JSON.parse json else {}
      if data.type == \block =>
        blocktmp.get {name: data.data.name}
          .then (dom) ~> deserialize dom
          .then (ret) ~>
            ta.parentNode.insertBefore ret.node, ta
            @editable.fire \change
          .catch -> console.log it

    else
      # prevent from inserting to self
      if ld$.parent ta, null, n => return
      # test if the container accept something like n
      if !(type = @typematch({p, n})) => return
      # hostable type only accepts insertion under root element
      if (type .&. 1) =>
        while ta
          if ta.parentNode == p => break
          ta = ta.parentNode

      if ta.nodeType == Element.TEXT_NODE
        n.parentNode.removeChild n
        text = ta.textContent
        [
          document.createTextNode text.substring(0,so)
          n
          document.createTextNode text.substring(so)
        ].map -> ta.parentNode.insertBefore it, ta
        ta.parentNode.removeChild ta
      else
        n.parentNode.removeChild n
        ta.parentNode.insertBefore n, ta
      @editable.fire \change



window.editable.{}mod.register \dragger, hub
