<-(->it!) _

get-code = (name) ->
  return switch name
  | \button => {"type":"tag","name":"div","style":[],"attr":[],"cls":["btn","btn-primary"],"child":[{"type":"text","value":" Button ","child":[]}]}
  | \list => {"type":"tag","name":"ul","style":[],"attr":[],"cls":[],"child":[{"type":"tag","name":"li","style":[],"attr":[],"cls":[],"child":[{"type":"text","value":"List","child":[]}]}]}
  | \image => {"type":"tag","name":"img","style":[],"attr":[["src","https://www.google.com/logos/doodles/2020/december-holidays-days-2-30-6753651837108830.5-s.png"]],"cls":[],"child":[]}
  | \table => {"type":"tag","name":"table","style":[],"attr":[],"cls":[],"child":[{"type":"tag","name":"tbody","style":[],"attr":[],"cls":[],"child":[{"type":"tag","name":"tr","style":[],"attr":[],"cls":[],"child":[{"type":"tag","name":"td","style":[],"attr":[],"cls":[],"child":[{"type":"text","value":"table","child":[]}]}]}]}]}
  | otherwise => {"type":"tag","name":"span","style":[],"attr":[],"cls":[],"child":[{"type":"text","value":"dummy","child":[]}]}

main = do
  events: do
    dragstart: (e) ->
      n = e.target
      if !( ld$.parent n, '[ld=menu]' ) => return
      name = n.getAttribute(\data-name) or \unnamed
      data = do
        name: name
        dom: get-code(name)
        mode: n.getAttribute(\data-mode) or \block
      e.dataTransfer
        ..setData \application/json, JSON.stringify(data)
        ..setData "mode/#{data.mode}", ''
        ..setDragImage main.ghost[data.mode], 10, 10
      e.stopPropagation!
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
  init: ->
    @mod.drag-insert = {}

window.editable.{}mod.register \drag-insert, main
