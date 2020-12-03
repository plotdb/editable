(function(it){
  return it();
})(function(){
  var mod, ref$;
  mod = {
    events: {
      mousemove: function(e){
        var n;
        n = ld$.parent(e.target, '[editable]', this.root);
        if (!(n && n.hasAttribute && n.hasAttribute('editable') && n.getAttribute('editable') !== 'false')) {
          return;
        }
        if (this.mod.fb.isFocused()) {
          return;
        }
        return this.mod.fb.setTarget(n);
      }
    },
    init: function(){
      var this$ = this;
      this.mod.fb = new focalbox({
        host: this.root
      });
      this.on('blur', function(){
        this$.mod.contenteditable.lock = false;
        return this$.mod.fb.focus(false);
      });
      return this.on('focus', function(arg$){
        var node;
        node = arg$.node;
        this$.mod.contenteditable.lock = true;
        this$.mod.fb.setTarget(node);
        return this$.mod.fb.focus(true);
      });
    }
  };
  return ((ref$ = window.editable).mod || (ref$.mod = {})).register('focalbox', mod);
});