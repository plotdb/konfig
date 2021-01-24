var bmgr, ctrl, configEditor;
bmgr = new block.manager();
ctrl = function(opt){
  opt == null && (opt = {});
  this.opt = import$({}, opt);
  this.evtHandler = {};
  return this;
};
ctrl.prototype = import$(Object.create(Object.prototype), {
  set: function(){},
  get: function(){},
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
  }
});
configEditor = function(opt){
  var this$ = this;
  opt == null && (opt = {});
  this.opt = import$({}, opt);
  this.def = opt.def;
  this.evtHandler = {};
  this.init = proxise(function(){
    if (this$.inited) {
      return Promise.resolve();
    } else if (!this$.initing) {
      return this$._init();
    }
  });
  return this;
};
configEditor.prototype = import$(Object.create(Object.prototype), {
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
  _init: function(){
    var this$ = this;
    this.initing = true;
    return Promise.resolve()['finally'](function(){
      return this.initing = false;
    }).then(function(){
      return this$.inited = true;
    });
  },
  get: function(){},
  set: function(){},
  parse: function(){
    var _, this$ = this;
    _ = function(n){
      var k, v;
      for (k in n) {
        v = n[k];
        if (!v) {
          continue;
        }
        if (v.type === 'group') {
          return _(v);
        }
        this$.ctrls[k] = new ctrl(v);
      }
    };
    return _(this.def);
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}