var ctrl, configEditor, bmgr;
ctrl = function(opt){
  opt == null && (opt = {});
  this.opt = import$({}, opt);
  this.name = opt.name;
  this.type = opt.type;
  this.group = opt.group;
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
  this.groups = {};
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
    var mkg, _, k, ref$, v, this$ = this, results$ = [];
    this.groups[''] = {
      child: {},
      root: this.root,
      key: ''
    };
    mkg = function(k, v){
      var root;
      root = document.createElement('div');
      root.classList.add('group');
      root.setAttribute('data-name', k);
      return this$.groups[k] = import$({
        child: {},
        root: root,
        key: k
      }, v || {});
    };
    _ = function(n, g){
      var k, v, results$ = [];
      for (k in n) {
        v = n[k];
        if (g.key) {
          v.group = g.key;
        }
        if (!v) {
          continue;
        }
        if (!this$.groups[v.group || '']) {
          mkg(v.group || '', {});
        }
        if (v.type === 'group') {
          mkg(k, v);
          _(v, this$.groups[k]);
          continue;
        }
        results$.push(this$.ctrls[k] = new ctrl(v));
      }
      return results$;
    };
    _(this.def, this.groups['']);
    for (k in ref$ = this.groups) {
      v = ref$[k];
      if (k) {
        results$.push(this.groups[v.group || ''].root.appendChild(v.root));
      }
    }
    return results$;
  },
  render: function(){
    var ps, k, v, this$ = this;
    ps = (function(){
      var ref$, results$ = [];
      for (k in ref$ = this.ctrls) {
        v = ref$[k];
        results$.push({
          k: k,
          v: v
        });
      }
      return results$;
    }.call(this)).map(function(arg$){
      var k, v, n;
      k = arg$.k, v = arg$.v;
      n = v.type;
      return bmgr.get({
        name: "ctrl-" + n,
        version: "0.0.1"
      }).then(function(it){
        return it.create();
      }).then(function(it){
        var node;
        node = this$.groups[v.group || ''].root;
        return it.attach({
          root: node
        });
      });
    });
    return Promise.all(ps);
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}