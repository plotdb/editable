(function(it){
  return it();
})(function(){
  var mod, ref$;
  mod = {
    events: {
      mouseover: function(e){
        var n;
        if (!((n = e.target) && e.target.hasAttribute)) {
          return;
        }
        if (!n.hasAttribute('resizable') || n.getAttribute('resizable') === 'false') {
          return;
        }
        if (n._itr) {
          return;
        }
        return n._itr = interact(n).resizable(mod.config.resizable);
      },
      mousedown: function(e){
        var n;
        if (!((n = e.target) && n._itr)) {
          return;
        }
        return n.setAttribute('draggable', false);
      }
    },
    config: {
      resizable: {
        edges: {
          top: true,
          left: true,
          bottom: true,
          right: true
        },
        listeners: {
          move: function(e){
            var d, nodes, boxes, dw;
            d = e.deltaRect;
            nodes = [e.target, null, null];
            if (d.left) {
              nodes[1] = nodes[0].previousSibling || nodes[0].nextSibling;
            }
            if (d.right) {
              nodes[2] = nodes[0].nextSibling || nodes[0].previousSibling;
            }
            nodes = nodes.map(function(it){
              if (!(it && it.getBoundingClientRect)) {
                return null;
              } else {
                return it;
              }
            });
            boxes = nodes.map(function(it){
              if (!it) {
                return null;
              } else {
                return it.getBoundingClientRect();
              }
            });
            nodes.map(function(d, i){
              if (d && !d.w) {
                return d.w = boxes[i].width;
              }
            });
            if (nodes[2]) {
              dw = d.right;
              nodes[0].w = nodes[0].w + dw;
              nodes[2].w = nodes[2].w - dw;
              nodes[0].style.width = nodes[0].w + "px";
              nodes[2].style.width = nodes[2].w + "px";
            }
            if (nodes[1]) {
              dw = d.left;
              nodes[0].w = nodes[0].w - dw;
              nodes[1].w = nodes[1].w + dw;
              nodes[0].style.width = (boxes[0].width - dw) + "px";
              nodes[1].style.width = (boxes[1].width + dw) + "px";
            }
            if (!(nodes[1] && nodes[2])) {
              nodes[0].style.height = e.rect.height + "px";
            }
            return nodes.filter(function(it){
              return it;
            }).map(function(it){
              var b;
              b = it.getBoundingClientRect();
              return it.innerText = b.width;
            });
          }
        }
      }
    },
    init: function(){}
  };
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('resize', mod);
});