<-(->it!) _

# TODO drag-insert / insert / typematch parameter `display`: better name?

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
      # TODO how can we determine display by the source data while we can't access dataTransfer?
      d.render {display: \inline} <<< ret{range}
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
  typematch: ({node,parent,display}) ->
    [n,p,d,type] = [node,parent,display,0]
    if !(p and (n or d)) => return 0
    d = (if d => d else if n => getComputedStyle(n).display else '') or \inline
    # block
    if p.hasAttribute(\hostable) and !/inline/.exec(d) => type += 1
    # inline-block
    if p.hasAttribute(\editable) and p.getAttribute(\editable) != \false and /inline/.exec(d) => type += 2
    return type

  render: (opt={}) ->
    range = opt.range
    if !range => return @caret.box.style <<< display: \none
    parent = ld$.parent range.startContainer, "[hostable],[editable]:not([editable=false])", @root
    insertable = @typematch {parent} <<< (if @src => {node: @src} else opt{display})

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
    parent = ld$.parent range.startContainer, "[hostable],[editable]:not([editable=false])", @root
    if !parent => return

    # src exists - user is dragging inner element.
    if @src => return @insert {range, parent, node: @src}

    # src doesn't exist - unknown data source. we parse dataTransfer for further information
    data = if (json = evt.dataTransfer.getData \application/json) => JSON.parse json else {}
    if data.type == \block =>
      blocktmp.get {name: data.data.name}
        .then (dom) ~> deserialize dom
        .then (ret) ~>
          ta.parentNode.insertBefore ret.node, ta
          @editable.fire \change
        .catch -> console.log it
    else
      # test code
      node = document.createElement(if data.display == \block => \div else \span)
      node.setAttribute \editable, true
      node.innerText = JSON.stringify(data)
      node.innerHTML = switch data.name
      | \button => """<div class="btn btn-primary"> Button </div>"""
      | \list => """<ul><li>List</li></ul>"""
      | \image => """<img src="https://www.google.com/logos/doodles/2020/december-holidays-days-2-30-6753651837108830.5-s.png"/>"""
      | \table => """<table><tr><td>table</td></tr></table>"""
      | otherwise => """dummy"""
      @insert {range, parent, node, display: (data.display or 'inline')}

  insert: ({parent, range, node, display}) ->
    [p,r,n,d] = [parent, range, node, display]

    sc = range.startContainer
    so = range.startOffset
    ta = if sc.nodeType == Element.TEXT_NODE => sc else sc.childNodes[so]

    # prevent from inserting to self
    if ld$.parent ta, null, n => return
    # test if the container accept something like n
    if !(type = @typematch({parent: p, node: n, display: d})) => return
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
      if display == \block =>
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
