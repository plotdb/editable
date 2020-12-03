<-(->it!) _

main = do
  events: do
    dragstart: (e) ->
      n = e.target
      data = {name: n.getAttribute(\data-name)}
      if data.name == \table => data.display = \block
      e.dataTransfer.setData(\application/json, JSON.stringify(data))
      e.dataTransfer.setDragImage(main.ghost,10,10)
      e.stopPropagation!
  ghost: (new Image!) <<< src: "data:image/svg+xml," + encodeURIComponent("""
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="15" viewBox="0 0 20 15">
    <rect x="0" y="0" width="20" height="15" fill="rgba(0,0,0,.5)"/>
    </svg>""")
  init: ->
    @mod.drag-insert = {}

window.editable.{}mod.register \drag-insert, main