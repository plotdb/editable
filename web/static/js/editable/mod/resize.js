(function(it){
  return it();
})(function(){
  var mod, ref$;
  mod = {
    events: {
      mouseover: function(e){
        var n, isInline, edges, ref$;
        if (!((n = e.target) && e.target.hasAttribute)) {
          return;
        }
        if (!n.hasAttribute('resizable') || n.getAttribute('resizable') === 'false') {
          return;
        }
        if (n._itr) {
          return;
        }
        n.style.touchAction = 'none';
        isInline = /inline/.exec(getComputedStyle(n).display);
        edges = {
          top: !isInline,
          left: !isInline,
          bottom: true,
          right: true
        };
        n._itr = interact(n).resizable((ref$ = mod.config.resizable, ref$.edges = edges, ref$));
        return n.addEventListener('click', function(e){
          if (e.target.getAttribute('draggable') === 'true') {
            return;
          }
          return e.stopPropagation();
        });
      },
      mousedown: function(e){
        var n, box, ref$, x, y, min;
        if (!((n = e.target) && n._itr && n.getBoundingClientRect)) {
          return;
        }
        box = n.getBoundingClientRect();
        ref$ = [e.clientX, e.clientY], x = ref$[0], y = ref$[1];
        min = Math.min.apply(Math, [box.x - x, box.y - y, box.x + box.width - x, box.y + box.height - y].map(function(it){
          return Math.abs(it);
        }));
        return n.setAttribute('draggable', min >= 20 ? 'true' : 'false');
      }
    },
    config: {
      resizable: {
        edges: {
          top: false,
          left: false,
          bottom: true,
          right: true
        },
        listeners: {
          move: function(e){
            var draggable, lockRatio, d, nodes, boxes, display, ref$, dw, dh, dir, favorW;
            draggable = mod.config.resizable.edges;
            lockRatio = e.shiftKey;
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
                d.w = boxes[i].width;
              }
              if (d && !d.h) {
                return d.h = boxes[i].height;
              }
            });
            display = getComputedStyle(nodes[0]).display;
            if (/inline/.exec(display)) {
              ref$ = [0, 0, 0], dw = ref$[0], dh = ref$[1], dir = ref$[2];
              if (d.left) {
                ref$ = [-d.left, dir + 1], dw = ref$[0], dir = ref$[1];
              }
              if (d.right) {
                ref$ = [d.right, dir + 4], dw = ref$[0], dir = ref$[1];
              }
              if (d.top) {
                ref$ = [-d.top, dir + 2], dh = ref$[0], dir = ref$[1];
              }
              if (d.bottom) {
                ref$ = [d.bottom, dir + 8], dh = ref$[0], dir = ref$[1];
              }
              if (lockRatio) {
                favorW = dir & 5 && dir & 10
                  ? dw > dh ? true : false
                  : dir & 5 ? true : false;
                if (favorW) {
                  dh = dw / nodes[0].w * nodes[0].h;
                } else {
                  dw = dh / nodes[0].h * nodes[0].w;
                }
              }
              nodes[0].w = nodes[0].w + dw;
              nodes[0].h = nodes[0].h + dh;
              nodes[0].style.width = nodes[0].w + "px";
              return ref$ = nodes[0].style, ref$.height = nodes[0].h + "px", ref$;
            } else {
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
                return ref$ = nodes[0].style, ref$.height = e.rect.height + "px", ref$;
              }
            }
          }
        }
      }
    },
    init: function(){}
  };
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('resize', mod);
});