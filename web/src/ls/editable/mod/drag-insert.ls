<-(->it!) _

main = do
  events: do
    dragstart: (e) ->
      n = e.target
      if !( ld$.parent n, '[ld=menu]' ) => return
      data = do
        name: n.getAttribute(\data-name) or \unnamed
        mode: n.getAttribute(\data-mode) or \block
      e.dataTransfer
        ..setData \application/json, JSON.stringify(data)
        ..setData "mode/#{data.mode}", JSON.stringify(data)
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
