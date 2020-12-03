(function(it){
  return it();
})(function(){
  /* sample code for getting prev node.
  get-prev = (n) ->
    if !n.previousSibling => return n.parentNode
    n = n.previousSibling
    while true
      if !n.childNodes or !n.childNodes[* - 1] => break
      n = n.childNodes[* - 1]
    return n
  */
  var getNext, showSelectedNodes, pp, ref$;
  getNext = function(n){
    var that;
    if (n.childNodes && n.childNodes.length) {
      return n.childNodes[0];
    }
    if (that = n.nextSibling) {
      return that;
    }
    for (;;) {
      n = n.parentNode;
      if (!n) {
        return null;
      }
      if (that = n.nextSibling) {
        return that;
      }
    }
  };
  showSelectedNodes = function(sel){
    var range, start, end, cur, i$, i, results$ = [];
    range = sel.getRangeAt(0);
    start = range.startContainer;
    end = range.endContainer;
    if (start.nodeType !== Element.TEXT_NODE) {
      start = start.childNodes[range.startOffset];
    }
    if (end.nodeType !== Element.TEXT_NODE) {
      end = end.childNodes[range.endOffset];
    }
    cur = start;
    for (i$ = 0; i$ < 100; ++i$) {
      i = i$;
      cur = getNext(cur);
      if (!cur || cur === end) {
        break;
      }
    }
    return results$;
  };
  pp = {
    events: {
      copy: function(e){
        var sel;
        sel = document.getSelection();
        showSelectedNodes(sel);
        e.clipboardData.setData('text/plain', sel.toString());
        return e.preventDefault();
      },
      paste: function(e){
        var data;
        data = e.clipboardData.getData('text/plain');
        document.execCommand('insertText', false, data);
        return e.preventDefault();
      }
    },
    init: function(){
      var k, v, this$ = this;
      this.mod.plainpase = {};
      return (function(){
        var ref$, results$ = [];
        for (k in ref$ = pp.events) {
          v = ref$[k];
          results$.push({
            k: k,
            v: v
          });
        }
        return results$;
      }()).map(function(arg$){
        var k, v;
        k = arg$.k, v = arg$.v;
        return document.addEventListener(k, function(e){
          return v.call(this$, e);
        });
      });
    }
  };
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('plainpaste', pp);
});