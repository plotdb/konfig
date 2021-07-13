var config;
config = function(opt){
  var this$ = this;
  opt == null && (opt = {});
  this.root = typeof opt.root === 'string'
    ? document.querySelector(opt.root)
    : opt.root;
  this.opt = opt;
  this.evtHandler = {};
  this.useBundle = opt.useBundle != null ? opt.useBundle : true;
  this._ctrlobj = {};
  this._ctrllist = [];
  this._tabobj = {};
  this._tablist = [];
  this._meta = opt.meta || {};
  this._tab = opt.tab || {};
  this._val = {};
  this.typemap = opt.typemap || null;
  this.mgr = this.mgrFallback = new block.manager({
    registry: function(arg$){
      var name, version, path;
      name = arg$.name, version = arg$.version, path = arg$.path;
      throw new Error("@plotdb/config: " + name + "@" + version + " is not supported");
    }
  });
  if (opt.manager) {
    this.mgr = opt.manager;
    this.mgr.setFallback(this.mgrFallback);
  }
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
  meta: function(it){
    if (!(it != null)) {
      return this._meta;
    }
    this._meta = it;
    return this.render();
  },
  tab: function(it){
    if (!(it != null)) {
      return this._tab;
    }
    this._tab = it;
    return this.render();
  },
  get: function(){
    return JSON.parse(JSON.stringify(this._val));
  },
  set: function(it){
    this._val = JSON.parse(JSON.stringify(it));
    return this.render();
  },
  _update: function(){
    return this.fire('change', this._val);
  },
  _init: function(){
    var this$ = this;
    return this.mgr.init().then(function(){
      if (this$.useBundle) {
        return config.bundle || [];
      } else {
        return [];
      }
    }).then(function(data){
      return this$.mgr.set(data.map(function(d){
        return new block['class']((d.manager = this$.mgr, d));
      }));
    }).then(function(){
      return this$.build();
    });
  },
  _prepareTab: function(tab){
    var ref$, root, d;
    if (this._tabobj[tab.id]) {
      return ref$ = this._tabobj[tab.id], ref$.tab = tab, ref$;
    }
    root = document.createElement('div');
    this._tablist.push(d = {
      root: root,
      tab: tab,
      key: Math.random().toString(36).substring(2)
    });
    return this._tabobj[tab.id] = d;
  },
  _prepareCtrl: function(meta, val, ctrl){
    var id, ref$, name, version, path, ret, this$ = this;
    id = meta.id;
    if (ctrl[id]) {
      return Promise.resolve();
    }
    if (meta.block) {
      ref$ = {
        name: (ref$ = meta.block).name,
        version: ref$.version,
        path: ref$.path
      }, name = ref$.name, version = ref$.version, path = ref$.path;
    } else if (this.typemap && (ret = this.typemap(meta.name))) {
      name = ret.name, version = ret.version, path = ret.path;
    } else {
      ref$ = [meta.name, "0.0.1", ''], name = ref$[0], version = ref$[1], path = ref$[2];
    }
    return this.mgr.get({
      name: name,
      version: version,
      path: path
    }).then(function(it){
      return it.create({
        data: meta
      });
    }).then(function(itf){
      var root;
      root = document.createElement('div');
      if (!(meta.tab != null)) {
        meta.tab = 'default';
      }
      if (!this$._tabobj[meta.tab]) {
        this$._prepareTab({
          id: meta.tab
        });
      }
      this$._ctrllist.push(ctrl[id] = {
        itf: itf,
        meta: meta,
        root: root,
        key: Math.random().toString(36).substring(2)
      });
      return itf.attach({
        root: root
      }).then(function(){
        return itf['interface']();
      });
    }).then(function(item){
      var v;
      val[id] = v = item.get();
      this$.update();
      return item.on('change', function(it){
        val[id] = it;
        return this$.update();
      });
    }).then(function(){
      return ctrl[id];
    });
  },
  _view: function(){
    var this$ = this;
    return this.view = new ldview({
      root: this.root,
      handler: {
        config: {
          list: function(){
            return this$._ctrllist;
          },
          key: function(it){
            return it.key;
          },
          init: function(arg$){
            var node, data;
            node = arg$.node, data = arg$.data;
            return node.appendChild(data.root);
          }
        }
      }
    });
  },
  _viewAlt: function(){
    var this$ = this;
    this._tablist.sort(function(a, b){
      return b.tab.order - a.tab.order;
    });
    return this.view = new ldview({
      root: this.root,
      handler: {
        tab: {
          list: function(){
            return this$._tablist;
          },
          key: function(it){
            return it.key;
          },
          view: {
            text: {
              name: function(arg$){
                var ctx;
                ctx = arg$.ctx;
                return ctx.tab.id;
              }
            },
            handler: {
              config: {
                list: function(arg$){
                  var ctx;
                  ctx = arg$.ctx;
                  return this$._ctrllist.filter(function(it){
                    return it.meta.tab === ctx.tab.id;
                  });
                },
                key: function(it){
                  return it.key;
                },
                init: function(arg$){
                  var node, data;
                  node = arg$.node, data = arg$.data;
                  return node.appendChild(data.root);
                }
              }
            }
          }
        }
      }
    });
  },
  build: function(clear){
    var this$ = this;
    clear == null && (clear = false);
    this._buildTab(clear);
    return this._buildCtrl(clear).then(function(){
      return this$._viewAlt();
    });
  },
  _buildCtrl: function(clear){
    var promises, traverse, this$ = this;
    clear == null && (clear = false);
    promises = [];
    traverse = function(meta, val, ctrl){
      var ctrls, id, v, results$ = [];
      val == null && (val = {});
      ctrl == null && (ctrl = {});
      if (!meta) {
        return;
      }
      ctrls = meta.child ? meta.child : meta;
      if (!ctrls) {
        return;
      }
      for (id in ctrls) {
        v = ctrls[id];
        v.id = id;
        if (v.type) {
          promises.push(this$._prepareCtrl(v, val, ctrl));
          continue;
        }
        results$.push(traverse(v, val[id] || (val[id] = {}), ctrl[id] || (ctrl[id] = {})));
      }
      return results$;
    };
    if (clear && this._ctrllist) {
      this._ctrllist.map(function(arg$){
        var itf, root;
        itf = arg$.itf, root = arg$.root;
        if (itf.destroy) {
          itf.destroy();
        }
        if (root.parentNode) {
          return root.parentNode.removeChild(root);
        }
      });
    }
    if (clear || !this._val) {
      this._val = {};
    }
    if (clear || !this._ctrlobj) {
      this._ctrlobj = {};
    }
    if (clear || !this._ctrllist) {
      this._ctrllist = [];
    }
    traverse(this._meta, this._val, this._ctrlobj);
    return Promise.all(promises);
  },
  _buildTab: function(clear){
    var traverse, this$ = this;
    clear == null && (clear = false);
    if (this.renderMode === 'ctrl') {
      return;
    }
    if (clear && this._tablist) {
      this._tablist.map(function(arg$){
        var root;
        root = arg$.root;
        return root.parentNode.removeChild(root);
      });
    }
    if (clear || !this._tablist) {
      this._tablist = [];
    }
    if (clear || !this._tab) {
      this._tab = {};
    }
    traverse = function(tab){
      var list, id, v, i$, len$, item, results$ = [];
      if (!tab) {
        return;
      }
      list = Array.isArray(tab)
        ? tab
        : (function(){
          var ref$, results$ = [];
          for (id in ref$ = tab) {
            v = ref$[id];
            results$.push({
              id: id,
              v: v
            });
          }
          return results$;
        }()).map(function(arg$, i){
          var id, v;
          id = arg$.id, v = arg$.v;
          if (!(v.order != null)) {
            v.order = i;
          }
          return v.id = id, v;
        });
      for (i$ = 0, len$ = list.length; i$ < len$; ++i$) {
        item = list[i$];
        this$._prepareTab(item);
        results$.push(traverse(item.child));
      }
      return results$;
    };
    return traverse(this._tab);
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
