<-(->it!) _

hide = (node) ->
  node.style <<< do
    pointerEvents: \none
    opacity: 0

mod = do
  events: do
    mousedown: -> hide @div
    contextmenu: (e) ->
      e.preventDefault!
      x = e.clientX
      y = e.clientY
      @div.style <<< do
        pointerEvents: \all
        opacity: 1
        left: "#{x}px"
        top: "#{y}px"

  init: ->
    @div = ld$.create name: \div
    @div.innerText = 'hello world'
    @div.style <<< do
      position: \absolute
      cursor: \pointer
      pointerEvents: \none
      opacity: 0
      transition: 'opacity .15s ease-out'
      padding: '.5em 1em'
      border: '1px solid #e1e2e3'
      borderRadius: \.25em
      boxShadow: '0 3px 3px rgba(0,0,0,.1)'
      background: \#fff
      zIndex: 10000
    @div.addEventListener \mousedown, (e) ->
      e.preventDefault!
      e.stopPropagation!
    @div.addEventListener \click, (e) -> hide @
    document.body.appendChild @div


window.editable.{}mod.register \context, mod

