editable = (opt={}) ->
  @opt = opt
  @evt-handler = {}
  # we modualize functionalities into mod, and keep their locals in @mod
  @mod = {}
  @ <<< opt{root}
  @root = if typeof(opt.root) == \string => ld$.find(opt.root, 0) else opt.root
  @fb = new focalbox {host: @root}
  @drag = new dragger {root: @root}
  @

editable.mod = do
  list: []
  register: (name, mod) -> @list.push {name,mod}

editable.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  init: ->
    [v for k,v of editable.mod.list].map ~> it.mod.init.call @

    document.addEventListener \mousemove, debounce(10, (e) ~>
      n = ld$.parent e.target, '[editable]', @root
      if !(n and n.hasAttribute and n.hasAttribute(\editable) and (n.getAttribute(\editable) != \false)) => return
      if @fb.is-focused! => return
      @fb.set-target n
    )

    @on \blur, ~>
      @mod.contenteditable.lock = false
      @fb.focus false
    @on \focus, ({node}) ~>
      @mod.contenteditable.lock = true
      @fb.set-target node
      @fb.focus true

