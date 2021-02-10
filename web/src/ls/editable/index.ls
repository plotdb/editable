editable = (opt={}) ->
  @opt = opt
  @evt-handler = {}
  # we modualize functionalities into mod, and keep their locals in @mod
  @mod = {}
  @ <<< opt{root}
  @root = if typeof(opt.root) == \string => ld$.find(opt.root, 0) else opt.root
  @

# We modularize functions and features with editable.mod and individual files 
# to make it easier to maintain this complex system
editable.mod = do
  list: []
  register: (name, mod) -> @list.push {name,mod}

editable.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  init: ->
    [v for k,v of editable.mod.list].map (m) ~>
      # init each module ( mod.init ) , and register event listener for each of them. ( mod.events )
      m.mod.init.call @
      ({k,v}) <~ [{k,v} for k,v of (m.mod.events or {})].map _
      document.addEventListener k, (e) ~> v.call @, e
      if m.mod.contextmenu => @{}contextmenu[m.mod.contextmenu.name] = m.mod.contextmenu
