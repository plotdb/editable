editable = (opt={}) ->
  @opt = opt
  @ <<< opt{root}
  @root = if typeof(opt.root) == \string => ld$.find(opt.root, 0) else opt.root

  @

editable.prototype = Object.create(Object.prototype) <<< do
  init: ->
    [{k,v} for k,v of contenteditable-dynamics.events].map ({k,v}) ~>
      document.addEventListener k, (e) ~> v.call @, e

