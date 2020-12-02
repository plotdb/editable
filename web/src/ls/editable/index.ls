editable = (opt={}) ->
  @opt = opt
  @evt-handler = {}
  @ <<< opt{root}
  @root = if typeof(opt.root) == \string => ld$.find(opt.root, 0) else opt.root
  @fb = new focalbox {host: @root}
  @drag = new dragger {root: @root}
  @

editable.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  init: ->
    [{k,v} for k,v of contenteditable-dynamics.events].map ({k,v}) ~>
      document.addEventListener k, (e) ~> v.call @, e
    document.addEventListener \keyup, (e) ~>
      if e.which == 27 =>
        contenteditable-dynamics.set-editable.call @, {target: null}

    document.addEventListener \mousemove, debounce(10, (e) ~>
      n = ld$.parent e.target, '[editable]', @root
      if !(n and n.hasAttribute and n.hasAttribute(\editable) and (n.getAttribute(\editable) != \false)) => return
      if @fb.is-focused! => return
      @fb.set-target n
    )
    @on \blur, ~>
      @active-lock = false
      @fb.focus false
    @on \focus, ({node}) ~>
      @active-lock = true
      @fb.set-target node
      @fb.focus true

