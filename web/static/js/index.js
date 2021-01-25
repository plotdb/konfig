var ctrl, configEditor, bmgr;
ctrl = function(opt){
  opt == null && (opt = {});
  this.opt = import$({}, opt);
  this.name = opt.name;
  this.type = opt.type;
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
  this.root = typeof opt.root === 'string'
    ? document.querySelector(opt.root)
    : opt.root;
  this.def = opt.def;
  this.evtHandler = {};
  this.ctrls = {};
  this.init = proxise.once(function(){
    return this$._init();
  });
  this.init();
  return this;
};
configEditor.bmgr = bmgr = new block.manager();
configEditor.types = ['choice', 'boolean', 'palette', 'color', 'number', 'text', 'paragraph', 'upload', 'font'];
configEditor.init = proxise(function(){
  return bmgr.init().then(function(){
    return configEditor.types.map(function(n){
      return bmgr.set({
        name: "ctrl-" + n,
        version: '0.0.1',
        block: new block['class']({
          root: "#ctrl-" + n
        })
      });
    });
  });
});
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
    return configEditor.init();
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
  },
  render: function(){
    var ps, res$, k, ref$, v, n, this$ = this;
    res$ = [];
    for (k in ref$ = this.ctrls) {
      v = ref$[k];
      n = v.type;
      res$.push(bmgr.get({
        name: "ctrl-" + n,
        version: "0.0.1"
      }).then(fn$).then(fn1$));
    }
    ps = res$;
    return Promise.all(ps);
    function fn$(it){
      return it.create();
    }
    function fn1$(it){
      return it.attach({
        root: this$.root
      });
    }
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}