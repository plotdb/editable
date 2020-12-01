var editable;
editable = function(opt){
  opt == null && (opt = {});
  this.opt = opt;
  this.root = opt.root;
  this.root = typeof opt.root === 'string'
    ? ld$.find(opt.root, 0)
    : opt.root;
  return this;
};
editable.prototype = import$(Object.create(Object.prototype), {
  init: function(){
    var k, v, this$ = this;
    return (function(){
      var ref$, results$ = [];
      for (k in ref$ = contenteditableDynamics.events) {
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
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}