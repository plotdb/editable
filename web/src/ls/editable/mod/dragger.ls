<-(->it!) _

/*
interface
 - e.dataTransfer ( drag data )
   - application/json - json in datadom format
   - mode/<mode> - determine display type. possible values:
     - inline
     - block
*/

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
      if !(@mod.dragger.contains e.target) => return
      d = @mod.dragger
      d.src = e.target
      mode = if /inline/.exec(getComputedStyle(d.src).display) => \inline else \block
      data = {mode}
      e.dataTransfer
        ..setData \application/json, JSON.stringify(data)
        ..setData "mode/#{mode}", ''
        ..setDragImage hub.ghost[mode], 10, 10
      d.set-drag true
      e.stopPropagation!

    dragover: (e) ->
      # always preventDefault even if not in range, otherwise drop won't be triggered.
      e.preventDefault!
      d = @mod.dragger
      ret = ldCaret.by-ptr {node: @root, x: e.clientX, y: e.clientY, method: \euclidean}
      if !d.contains(ret.range.startContainer) => return
      mode = e.dataTransfer.types.map(->/mode\/(.+)/.exec(it)).filter(->it).map(->it.1).0 or \inline
      d.render({} <<< ret{range} <<< {mode})
    drop: (e) ->
      [n,d] = [e.target, @mod.dragger]
      e.preventDefault!
      d.drop {evt: e}
  ghost: do
    block: (new Image!) <<< src: "data:image/svg+xml," + encodeURIComponent("""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="15" viewBox="0 0 20 15">
    <rect x="0" y="0" width="9" height="15" fill="rgba(0,0,0,.5)"/>
    <rect x="11" y="0" width="9" height="15" fill="rgba(0,0,0,.5)"/>
    </svg>""")
    inline: (new Image!) <<< src: "data:image/svg+xml," + encodeURIComponent("""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="15" viewBox="0 0 20 15">
    <rect x="0" y="0" width="20" height="3" fill="rgba(0,0,0,.5)"/>
    <rect x="0" y="4" width="20" height="3" fill="rgba(0,0,0,.5)"/>
    <rect x="0" y="8" width="20" height="3" fill="rgba(0,0,0,.5)"/>
    <rect x="0" y="12" width="20" height="3" fill="rgba(0,0,0,.5)"/>
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
  hostmatch: ({parent,mode}) ->
    while parent
      if parent.hasAttribute
        type = 0
        # block
        if mode == \block and parent.hasAttribute(\hostable) => type += 1
        # inline-block
        if mode == \inline and parent.hasAttribute(\editable) and
        parent.getAttribute(\editable) != \false => type += 2
        if type => return {parent, type}
      if (parent = parent.parentNode) == @root => parent = null
    return {parent, type}

  render: (opt={}) ->
    range = opt.range
    if !range => return @caret.box.style <<< display: \none
    {parent, type} = @hostmatch {parent: range.startContainer, mode: opt.mode}
    insertable = type

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
    [range,node] = [@caret.range, @src]
    @src = null
    # always render(null) to clear since we might have already rendered before and not yet clear it.
    @render!
    if !(range and @root.contains(evt.target)) => return
    parent = range.startContainer

    # src node exists - user is dragging inner element.
    mode = evt.dataTransfer.types.map(->/mode\/(.+)/.exec(it)).filter(->it).map(->it.1).0 or \inline
    if node => return @insert {range, parent, mode, node}

    # src node doesn't exist - unknown data source. we parse dataTransfer for further information
    data = if (json = evt.dataTransfer.getData \application/json) => JSON.parse json else {}
    console.log data
    if data.type == \block =>
      plugin = ->
        n = document.createElement \div
        n.innerText = 'Hello World!'
        return {node: n}
      datadom.deserialize data.dom, plugin
        .then (ret) ~>
          n = ret.node
          n.setAttribute \editable, true
          n.setAttribute \draggable, true
          @insert {range, parent, node: ret.node, mode: (data.mode or 'block')}
    else
      # test code
      node = document.createElement(if data.mode == \block => \div else \span)
      node.setAttribute \editable, true
      node.setAttribute \draggable, true
      datadom.deserialize data.dom
        .then (ret) ->
          node.innerHTML = ""
          node.appendChild ret.node
      @insert {range, parent, node, mode: (data.mode or 'block')}

  insert: ({parent, range, node, mode}) ->
    [p,r,n,m] = [parent, range, node, mode]

    sc = range.startContainer
    so = range.startOffset
    ta = if sc.nodeType == Element.TEXT_NODE => sc else sc.childNodes[so]

    # prevent from inserting to self
    if ld$.parent ta, null, n => return
    # test if the container accept something like n
    {parent,type} = @hostmatch({parent: p, mode: m})
    if !(p = parent) => return
    # hostable type only accepts insertion under root element
    if (type .&. 1) =>
      while ta
        if ta.parentNode == p => break
        ta = ta.parentNode

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
      if n.parentNode => n.parentNode.removeChild n
      if mode == \block =>
        # we are going to insert block node. determine before / after according to caret position
        r1 = document.createRange!
        r2 = document.createRange!
        r1.setStart p, 0
        r1.setEnd sc, so
        r2.setStart sc, so
        r2.setEnd(
          (p.nextSibling or p),
          if p.nextSibling => 0 else if p.childNodes => p.childNodes.length else p.textContent.length
        )
        lstr = r1.toString!length
        rstr = r2.toString!length
        if lstr > rstr => ta.parentNode.insertBefore n, ta.nextSibling
        else ta.parentNode.insertBefore n, ta
      else ta.parentNode.insertBefore n, ta

    @editable.fire \change




window.editable.{}mod.register \dragger, hub
