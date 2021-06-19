(function(){
var config;
config = function(opt){
  var this$ = this;
  opt == null && (opt = {});
  this.root = typeof opt.root === 'string'
    ? document.querySelector(opt.root)
    : opt.root;
  this.evtHandler = {};
  this.cfg = opt.config || {};
  this.value = {};
  this.name = opt.name || null;
  opt.debug = true;
  this.mgr = new block.manager({
    registry: opt.debug
      ? function(arg$){
        var name, version;
        name = arg$.name, version = arg$.version;
        return "/block/" + name + "/" + version + "/index.html";
      }
      : function(arg$){
        var name, version;
        name = arg$.name, version = arg$.version;
        throw new Error(name + "@" + version + " is not supported");
      }
  });
  this.init = proxise.once(function(){
    return this$._init();
  });
  this.update = debounce(150, function(){
    return this$._update();
  });
  return this;
};
config.prototype = import$(Object.create(Object.prototype), {
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
  render: function(){
    return this.view.render();
  },
  config: function(it){
    if (it != null) {
      return this.cfg = it;
    } else {
      return this.cfg;
    }
  },
  _init: function(){
    var this$ = this;
    return this.mgr.init().then(function(){
      return this$.view = new ldview({
        root: this$.root,
        handler: {
          config: {
            list: function(){
              var k, v;
              return (function(){
                var ref$, results$ = [];
                for (k in ref$ = this.cfg) {
                  v = ref$[k];
                  results$.push({
                    k: k,
                    v: v
                  });
                }
                return results$;
              }.call(this$)).map(function(it){
                var ret;
                ret = import$({}, it.v);
                if (!ret.name) {
                  ret.name = it.k;
                }
                return ret;
              });
            },
            key: function(it){
              return it.name;
            },
            init: function(arg$){
              var node, data;
              node = arg$.node, data = arg$.data;
              return this$._prepare({
                name: data.type,
                root: node,
                data: data
              });
            }
          }
        }
      });
    });
  },
  _update: function(){
    return this.fire('change', this.value);
  },
  _prepare: function(arg$){
    var name, root, data, this$ = this;
    name = arg$.name, root = arg$.root, data = arg$.data;
    if (this.name) {
      name = this.name(name);
    }
    return this.mgr.get({
      name: name,
      version: "0.0.1"
    }).then(function(it){
      return it.create({
        data: data
      });
    }).then(function(bi){
      return bi.attach({
        root: root
      }).then(function(){
        return bi['interface']();
      });
    }).then(function(item){
      var v;
      this$.value[data.name] = v = item.get();
      this$.update();
      return item.on('change', function(it){
        this$.value[data.name] = it;
        return this$.update();
      });
    });
  }
});
if (typeof module != 'undefined' && module !== null) {
  module.exports = config;
} else if (typeof window != 'undefined' && window !== null) {
  window.config = config;
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
})();
