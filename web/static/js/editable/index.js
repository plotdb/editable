var editable;
editable = function(opt){
  opt == null && (opt = {});
  this.opt = opt;
  this.evtHandler = {};
  this.mod = {};
  this.root = opt.root;
  this.root = typeof opt.root === 'string'
    ? ld$.find(opt.root, 0)
    : opt.root;
  this.fb = new focalbox({
    host: this.root
  });
  this.drag = new dragger({
    root: this.root
  });
  return this;
};
editable.mod = {
  list: [],
  register: function(name, mod){
    return this.list.push({
      name: name,
      mod: mod
    });
  }
};
editable.prototype = import$(Object.create(Object.prototype), {
  on: function(n, cb){
    var ref$;
    return ((ref$ = this.evtHandler)[n] || (ref$[n] = [])).push(cb);
  },
  fire: function(n){
    var v, res$, i$, to$, ref$, len$, cb, results$ = [];
    res$ = [];
    for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
      res$.push(arguments[i$]);
    }
    v = res$;
    for (i$ = 0, len$ = (ref$ = this.evtHandler[n] || []).length; i$ < len$; ++i$) {
      cb = ref$[i$];
      results$.push(cb.apply(this, v));
    }
    return results$;
  },
  init: function(){
    var k, v, this$ = this;
    (function(){
      var ref$, results$ = [];
      for (k in ref$ = editable.mod.list) {
        v = ref$[k];
        results$.push(v);
      }
      return results$;
    }()).map(function(it){
      return it.mod.init.call(this$);
    });
    document.addEventListener('mousemove', debounce(10, function(e){
      var n;
      n = ld$.parent(e.target, '[editable]', this$.root);
      if (!(n && n.hasAttribute && n.hasAttribute('editable') && n.getAttribute('editable') !== 'false')) {
        return;
      }
      if (this$.fb.isFocused()) {
        return;
      }
      return this$.fb.setTarget(n);
    }));
    this.on('blur', function(){
      this$.mod.contenteditable.lock = false;
      return this$.fb.focus(false);
    });
    return this.on('focus', function(arg$){
      var node;
      node = arg$.node;
      this$.mod.contenteditable.lock = true;
      this$.fb.setTarget(node);
      return this$.fb.focus(true);
    });
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}