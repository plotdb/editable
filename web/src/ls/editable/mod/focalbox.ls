<-(->it!) _

mod = do
  events: do
    mousemove: (e) ->
      n = ld$.parent e.target, '[editable]', @root
      if !(n and n.hasAttribute and n.hasAttribute(\editable) and (n.getAttribute(\editable) != \false)) => return
      if @mod.fb.is-focused! => return
      @mod.fb.set-target n

  init: ->
    @mod.fb = new focalbox {host: @root}
    @on \blur, ~>
      @mod.contenteditable.lock = false
      @mod.fb.focus false
    @on \focus, ({node}) ~>
      @mod.contenteditable.lock = true
      @mod.fb.set-target node
      @mod.fb.focus true


window.editable.{}mod.register \focalbox, mod
