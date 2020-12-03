(function(it){
  return it();
})(function(){
  var main, ref$;
  main = {
    events: {
      dragstart: function(e){
        var n, data, x$;
        n = e.target;
        if (!ld$.parent(n, '[ld=menu]')) {
          return;
        }
        data = {
          name: n.getAttribute('data-name') || 'unnamed',
          mode: n.getAttribute('data-mode') || 'block'
        };
        x$ = e.dataTransfer;
        x$.setData('application/json', JSON.stringify(data));
        x$.setData("mode/" + data.mode, JSON.stringify(data));
        x$.setDragImage(main.ghost, 10, 10);
        return e.stopPropagation();
      }
    },
    ghost: (ref$ = new Image(), ref$.src = "data:image/svg+xml," + encodeURIComponent("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"15\" viewBox=\"0 0 20 15\">\n<rect x=\"0\" y=\"0\" width=\"20\" height=\"15\" fill=\"rgba(0,0,0,.5)\"/>\n</svg>"), ref$),
    init: function(){
      return this.mod.dragInsert = {};
    }
  };
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('drag-insert', main);
});