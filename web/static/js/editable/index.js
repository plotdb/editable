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
    return (function(){
      var ref$, results$ = [];
      for (k in ref$ = editable.mod.list) {
        v = ref$[k];
        results$.push(v);
      }
      return results$;
    }()).map(function(m){
      var k, v;
      m.mod.init.call(this$);
      return (function(){
        var ref$, results$ = [];
        for (k in ref$ = m.mod.events || {}) {
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
        document.addEventListener(k, function(e){
          return v.call(this$, e);
        });
        if (m.mod.contextmenu) {
          return (this$.contextmenu || (this$.contextmenu = {}))[m.mod.contextmenu.name] = m.mod.contextmenu;
        }
      });
    });
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}