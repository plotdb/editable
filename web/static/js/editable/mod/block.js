(function(it){
  return it();
})(function(){
  var getCode, main, ref$;
  getCode = function(name){
    var ret;
    if (name === 'sample') {
      ret = {
        type: 'block',
        name: 'features',
        version: '0.0.1'
      };
      return ret;
    }
    return (function(){
      switch (name) {
      case 'button':
        return {
          "type": "tag",
          "name": "div",
          "style": [],
          "attr": [],
          "cls": ["btn", "btn-primary"],
          "child": [{
            "type": "text",
            "value": " Button ",
            "child": []
          }]
        };
      case 'list':
        return {
          "type": "tag",
          "name": "ul",
          "style": [],
          "attr": [],
          "cls": [],
          "child": [{
            "type": "tag",
            "name": "li",
            "style": [],
            "attr": [],
            "cls": [],
            "child": [{
              "type": "text",
              "value": "List",
              "child": []
            }]
          }]
        };
      case 'image':
        return {
          "type": "tag",
          "name": "img",
          "style": [],
          "attr": [["resizable", "true"], ["src", "https://www.google.com/logos/doodles/2020/december-holidays-days-2-30-6753651837108830.5-s.png"]],
          "cls": [],
          "child": []
        };
      case 'table':
        return {
          "type": "tag",
          "name": "table",
          "style": [],
          "attr": [],
          "cls": [],
          "child": [{
            "type": "tag",
            "name": "tbody",
            "style": [],
            "attr": [],
            "cls": [],
            "child": [{
              "type": "tag",
              "name": "tr",
              "style": [],
              "attr": [],
              "cls": [],
              "child": [{
                "type": "tag",
                "name": "td",
                "style": [],
                "attr": [],
                "cls": [],
                "child": [{
                  "type": "text",
                  "value": "table",
                  "child": []
                }]
              }]
            }]
          }]
        };
      default:
        return {
          "type": "tag",
          "name": "span",
          "style": [],
          "attr": [],
          "cls": [],
          "child": [{
            "type": "text",
            "value": "dummy",
            "child": []
          }]
        };
      }
    }());
  };
  main = {
    events: {
      dragstart: function(e){
        var n, name, data, x$;
        n = e.target;
        if (!ld$.parent(n, '[ld=menu]')) {
          return;
        }
        name = n.getAttribute('data-name') || 'unnamed';
        data = {
          name: name,
          dom: getCode(name),
          mode: n.getAttribute('data-mode') || 'block',
          type: 'block'
        };
        x$ = e.dataTransfer;
        x$.setData('application/json', JSON.stringify(data));
        x$.setData("mode/" + data.mode, '');
        x$.setDragImage(main.ghost[data.mode], 10, 10);
        return e.stopPropagation();
      }
    },
    ghost: {
      block: (ref$ = new Image(), ref$.src = "data:image/svg+xml," + encodeURIComponent("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"15\" viewBox=\"0 0 20 15\">\n<rect x=\"0\" y=\"0\" width=\"9\" height=\"15\" fill=\"rgba(0,0,0,.5)\"/>\n<rect x=\"11\" y=\"0\" width=\"9\" height=\"15\" fill=\"rgba(0,0,0,.5)\"/>\n</svg>"), ref$),
      inline: (ref$ = new Image(), ref$.src = "data:image/svg+xml," + encodeURIComponent("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"15\" viewBox=\"0 0 20 15\">\n<rect x=\"0\" y=\"0\" width=\"20\" height=\"3\" fill=\"rgba(0,0,0,.5)\"/>\n<rect x=\"0\" y=\"4\" width=\"20\" height=\"3\" fill=\"rgba(0,0,0,.5)\"/>\n<rect x=\"0\" y=\"8\" width=\"20\" height=\"3\" fill=\"rgba(0,0,0,.5)\"/>\n<rect x=\"0\" y=\"12\" width=\"20\" height=\"3\" fill=\"rgba(0,0,0,.5)\"/>\n</svg>"), ref$)
    },
    init: function(){
      return this.mod.block = {};
    }
  };
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('block', main);
});