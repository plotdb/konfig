(function(){
var konfig;
konfig = function(opt){
  var this$ = this;
  opt == null && (opt = {});
  this.root = typeof opt.root === 'string'
    ? document.querySelector(opt.root)
    : opt.root;
  this.opt = opt;
  this.evtHandler = {};
  this.useBundle = opt.useBundle != null ? opt.useBundle : true;
  this.view = opt.view;
  this.autotab = opt.autotab || false;
  this._ctrlobj = {};
  this._ctrllist = [];
  this._tabobj = {};
  this._tablist = [];
  this._template = null;
  this._meta = opt.meta || {};
  this._tab = opt.tab || {};
  this._val = {};
  this._obj = {};
  this._objps = [];
  this.typemap = opt.typemap || null;
  this.mgr = this.mgrChain = new block.manager({
    registry: function(arg$){
      var name, version, path;
      name = arg$.name, version = arg$.version, path = arg$.path;
      throw new Error("@plotdb/konfig: " + name + "@" + version + "/" + path + " is not supported");
    }
  });
  if (opt.manager) {
    this.mgr = opt.manager;
    this.mgr.chain(this.mgrChain);
  }
  this.init = proxise.once(function(){
    return this$._init();
  }, function(){
    return this$._val;
  });
  this._updateDebounced = debounce(150, function(n, v){
    return this$._update(n, v);
  });
  this.doDebounce = !(opt.debounce != null) || opt.debounce;
  this.update = function(n, v){
    if (this$.doDebounce) {
      return this$._updateDebounced(n, v);
    } else {
      return this$._update(n, v);
    }
  };
  return this;
};
konfig.views = {
  simple: function(){
    var this$ = this;
    return new ldview({
      root: this.root,
      initRender: false,
      handler: {
        ctrl: {
          list: function(){
            return this$._ctrllist.filter(function(it){
              return !it.meta.hidden;
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
    });
  },
  'default': function(){
    var this$ = this;
    return new ldview({
      root: this.root,
      initRender: false,
      handler: {
        tab: {
          list: function(){
            this$._tablist.sort(function(a, b){
              return b.tab.order - a.tab.order;
            });
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
              ctrl: {
                list: function(arg$){
                  var ctx;
                  ctx = arg$.ctx;
                  return this$._ctrllist.filter(function(it){
                    return it.meta.tab === ctx.tab.id && !it.meta.hidden;
                  });
                },
                key: function(it){
                  return it.key;
                },
                init: function(arg$){
                  var node, data;
                  node = arg$.node, data = arg$.data;
                  return node.appendChild(data.root);
                },
                handler: function(arg$){
                  var node, data;
                  node = arg$.node, data = arg$.data;
                  return data.itf.render();
                }
              }
            }
          }
        }
      }
    });
  },
  recurse: function(){
    var template, opt, this$ = this;
    if (this._template) {
      template = this._template;
    } else {
      template = ld$.find(this.root, '[ld=template]', 0);
      template.parentNode.removeChild(template);
      template.removeAttribute('ld-scope');
      this._template = template;
    }
    template = template.cloneNode(true);
    return new ldview(import$({
      ctx: {
        tab: {
          id: null
        }
      }
    }, import$(opt = {}, {
      template: template,
      root: this.root,
      initRender: false,
      text: {
        name: function(arg$){
          var ctx;
          ctx = arg$.ctx;
          return ctx.tab ? (ctx.tab.name || '') + "" : '';
        }
      },
      handler: {
        tab: {
          list: function(arg$){
            var ctx, tabs;
            ctx = arg$.ctx;
            tabs = this$._tablist.filter(function(it){
              return !(it.tab.parent.tab.id || ctx.tab.id) || (it.tab.parent && ctx.tab && it.tab.parent.tab.id === ctx.tab.id);
            });
            tabs.sort(function(a, b){
              return b.tab.order - a.tab.order;
            });
            return tabs;
          },
          key: function(it){
            return it.key;
          },
          view: opt
        },
        ctrl: {
          list: function(arg$){
            var ctx, ret;
            ctx = arg$.ctx;
            ret = this$._ctrllist.filter(function(it){
              if (!ctx.tab) {
                return false;
              }
              return it.meta.tab === ctx.tab.id && !it.meta.hidden;
            });
            return ret;
          },
          key: function(it){
            return it.key;
          },
          init: function(arg$){
            var node, data;
            node = arg$.node, data = arg$.data;
            return node.appendChild(data.root);
          },
          handler: function(arg$){
            var node, data;
            node = arg$.node, data = arg$.data;
            node.style.flex = "1 1 " + 16 * (data.meta.weight || 1) + "%";
            return data.itf.render();
          }
        }
      }
    })));
  }
};
konfig.prototype = import$(Object.create(Object.prototype), {
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
  render: function(clear){
    var payload;
    clear == null && (clear = false);
    if (!this.view) {
      return;
    }
    if (!this._view || clear === true) {
      if (typeof this.view === 'string') {
        this._view = this._view || konfig.views[this.view].apply(this);
      } else if (typeof this.view === 'function') {
        payload = {
          root: this.root,
          ctrls: this._ctrllist,
          tabs: this._tablist
        };
        this._view = this.view.apply(payload, [payload]);
      } else {
        this._view = this.view;
        this._view.ctx({
          root: this.root,
          ctrls: this._ctrllist,
          tabs: this._tablist
        });
      }
    }
    return this._view.render();
  },
  meta: function(o){
    var meta, tab, config;
    o == null && (o = {});
    o = JSON.parse(JSON.stringify(o));
    meta = o.meta, tab = o.tab, config = o.config;
    this._meta = {};
    this._tab = {};
    if (!(meta != null) || typeof meta.type === 'string') {
      this._meta = o;
      return this.build(true);
    } else {
      if (meta != null) {
        this._meta = meta;
      }
      if (tab != null) {
        this._tab = tab;
      }
      return this.build(true, config);
    }
  },
  'default': function(){
    var traverse, ret;
    traverse = function(meta, val, ctrl, pid){
      var ctrls, id, v, results$ = [];
      val == null && (val = {});
      ctrl == null && (ctrl = {});
      ctrls = meta.child ? meta.child : meta;
      for (id in ctrls) {
        v = ctrls[id];
        if (v.type) {
          results$.push(val[id] = ctrl[id].itf['default']());
        } else {
          results$.push(traverse(v, val[id] || (val[id] = {}), ctrl[id] || (ctrl[id] = {}), id));
        }
      }
      return results$;
    };
    traverse(this._meta, ret = {}, this._ctrlobj, null);
    return ret;
  },
  reset: function(){
    var nv;
    nv = this['default']();
    this.set(nv);
    return this._update();
  },
  get: function(){
    return JSON.parse(JSON.stringify(this._val));
  },
  _objwait: function(p){
    var ps;
    this._objps.push(p);
    if (this._objps.length < 100) {
      return;
    }
    ps = this._objps.splice(0);
    return this._objps.push(Promise.all(ps));
  },
  obj: function(){
    var this$ = this;
    return Promise.all(this._objps)['finally'](function(){
      return this$._objps.splice(0);
    }).then(function(){
      return this$._obj;
    });
  },
  set: function(nv, o){
    var traverse, this$ = this;
    o == null && (o = {});
    nv = JSON.parse(JSON.stringify(nv));
    this.render();
    traverse = function(meta, val, obj, nval, ctrl, pid){
      var ctrls, id, v, results$ = [];
      val == null && (val = {});
      obj == null && (obj = {});
      nval == null && (nval = {});
      ctrl == null && (ctrl = {});
      ctrls = meta.child ? meta.child : meta;
      for (id in ctrls) {
        v = ctrls[id];
        if (v.type) {
          if (val[id] !== nval[id] && !(o.append && !(nval[id] != null))) {
            val[id] = nval[id];
            ctrl[id].itf.set(val[id]);
            results$.push(fn$(id));
          }
        } else {
          results$.push(traverse(v, val[id] || (val[id] = {}), obj[id] || (obj[id] = {}), nval[id] || (nval[id] = {}), ctrl[id] || (ctrl[id] = {}), id));
        }
      }
      return results$;
      function fn$(id){
        return this$._objwait(ctrl[id].itf.object(val[id]).then(function(it){
          return obj[id] = it;
        }));
      }
    };
    return traverse(this._meta, this._val, this._obj, nv, this._ctrlobj, null);
  },
  _update: function(n, v){
    return this.fire('change', JSON.parse(JSON.stringify(this._val)), n, v);
  },
  _init: function(){
    var this$ = this;
    return this.mgr.init().then(function(){
      if (this$.useBundle) {
        return konfig.bundle || [];
      } else {
        return [];
      }
    }).then(function(data){
      return this$.mgr.set(data.map(function(d){
        return new block['class']((d.manager = this$.mgr, d));
      }));
    }).then(function(){
      return this$.build();
    }).then(function(){
      return this$._val;
    });
  },
  _prepareTab: function(tab){
    var ctab, root, d;
    if (this._tabobj[tab.id]) {
      ctab = this._tabobj[tab.id].tab;
      if (ctab.depth < tab.depth) {
        ctab.tab = tab;
      }
      return ctab;
    }
    root = document.createElement('div');
    this._tablist.push(d = {
      root: root,
      tab: tab,
      ctrls: [],
      tabs: [],
      key: "tabkey-" + this._tablist.length + "-" + Math.random().toString(36).substring(2)
    });
    return this._tabobj[tab.id] = d;
  },
  'interface': function(meta){
    var ref$, name, version, path, ret, ns, id, that, this$ = this;
    if (meta.block) {
      ref$ = {
        name: (ref$ = meta.block).name,
        version: ref$.version,
        path: ref$.path
      }, name = ref$.name, version = ref$.version, path = ref$.path;
    } else if (this.typemap && (ret = this.typemap(meta.type))) {
      ns = ret.ns, name = ret.name, version = ret.version, path = ret.path;
    } else {
      ref$ = ['', meta.type, konfig.version, ''], ns = ref$[0], name = ref$[1], version = ref$[2], path = ref$[3];
    }
    id = block.id({
      ns: ns,
      name: name,
      version: version,
      path: path
    });
    if (that = (this._lib || (this._lib = {}))[id]) {
      return Promise.resolve(that);
    }
    return this.mgr.get({
      ns: ns,
      name: name,
      version: version,
      path: path
    }).then(function(it){
      return it.create({
        data: meta
      });
    }).then(function(b){
      return b.attach().then(function(){
        return b['interface']();
      });
    }).then(function(itf){
      itf == null && (itf = {});
      return this$._lib[id] = itf;
    });
  },
  _prepareCtrl: function(meta, val, obj, ctrl){
    var id, ref$, name, version, path, ret, ns, this$ = this;
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
    } else if (this.typemap && (ret = this.typemap(meta.type))) {
      ns = ret.ns, name = ret.name, version = ret.version, path = ret.path;
    } else {
      ref$ = ['', meta.type, konfig.version, ''], ns = ref$[0], name = ref$[1], version = ref$[2], path = ref$[3];
    }
    return this.mgr.get({
      ns: ns,
      name: name,
      version: version,
      path: path
    }).then(function(it){
      return it.create({
        data: meta
      });
    }).then(function(b){
      var root, tabo;
      root = document.createElement('div');
      if (!(meta.tab != null)) {
        meta.tab = 'default';
      }
      tabo = !this$._tabobj[meta.tab]
        ? this$._prepareTab({
          id: meta.tab,
          name: meta.tab,
          depth: 0,
          parent: {
            tab: {}
          }
        })
        : this$._tabobj[meta.tab];
      this$._ctrllist.push(ctrl[id] = {
        block: b,
        meta: meta,
        root: root,
        key: "ctrlkey-" + this$._ctrllist.length + "-" + Math.random().toString(36).substring(2)
      });
      tabo.ctrls.push(ctrl[id]);
      return b.attach({
        root: root,
        defer: true
      }).then(function(){
        return b['interface']();
      }).then(function(it){
        return ctrl[id].itf = it;
      });
    }).then(function(item){
      var v;
      val[id] = v = item.get();
      this$._objwait(item.object(v).then(function(it){
        return obj[id] = it;
      }));
      return item.on('change', function(it){
        val[id] = it;
        this$._objwait(item.object(it).then(function(it){
          return obj[id] = it;
        }));
        return this$.update(id, it);
      });
    }).then(function(){
      return ctrl[id];
    });
  },
  build: function(clear, cfg){
    var this$ = this;
    clear == null && (clear = false);
    this._buildTab(clear);
    return this._buildCtrl(clear).then(function(){
      return this$._ctrllist.map(function(c){
        return c.block.attach();
      });
    }).then(function(){
      return this$.render(clear);
    }).then(function(){
      if (cfg != null) {
        return this$.set(cfg);
      }
    }).then(function(){
      return this$.update();
    });
  },
  _buildCtrl: function(clear){
    var promises, traverse, this$ = this;
    clear == null && (clear = false);
    promises = [];
    traverse = function(meta, val, obj, ctrl, pid, ptabo){
      var ctrls, tab, tabo, id, v, results$ = [];
      val == null && (val = {});
      obj == null && (obj = {});
      ctrl == null && (ctrl = {});
      if (!(meta && typeof meta === 'object')) {
        return;
      }
      ctrls = meta.child ? meta.child : meta;
      tab = meta.child ? meta.tab : null;
      if (!tab && this$.autotab && pid) {
        tab = "tabid-" + this$._tablist.length + "-" + Math.random().toString(36).substring(2);
        tabo = this$._prepareTab({
          id: tab,
          name: pid,
          depth: ptabo ? ptabo.tab.depth + 1 : 0,
          parent: ptabo
            ? ptabo
            : {
              tab: {}
            }
        });
        if (ptabo) {
          ptabo.tabs.push(tabo);
        }
      }
      if (!ctrls) {
        return;
      }
      for (id in ctrls) {
        v = ctrls[id];
        if (v.type) {
          import$((v.id = id, v), tab && !v.tab
            ? {
              tab: tab
            }
            : {});
          promises.push(this$._prepareCtrl(v, val, obj, ctrl));
          continue;
        }
        results$.push(traverse(v, val[id] || (val[id] = {}), obj[id] || (obj[id] = {}), ctrl[id] || (ctrl[id] = {}), id, tabo));
      }
      return results$;
    };
    if (clear && this._ctrllist) {
      this._ctrllist.map(function(arg$){
        var block, root;
        block = arg$.block, root = arg$.root;
        if (block.destroy) {
          block.destroy();
        }
        if (root.parentNode) {
          return root.parentNode.removeChild(root);
        }
      });
    }
    if (clear || !this._val) {
      this._val = {};
      this._obj = {};
    }
    if (clear || !this._ctrlobj) {
      this._ctrlobj = {};
    }
    if (clear || !this._ctrllist) {
      this._ctrllist = [];
    }
    traverse(this._meta, this._val, this._obj, this._ctrlobj, null);
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
        if (root.parentNode) {
          return root.parentNode.removeChild(root);
        }
      });
    }
    if (clear || !this._tablist) {
      this._tablist = [];
    }
    if (clear || !this._tab) {
      this._tab = {};
    }
    if (clear) {
      this._tabobj = {};
    }
    traverse = function(tab, depth, parent){
      var list, id, v, i$, to$, order, item, tabo, results$ = [];
      depth == null && (depth = 0);
      parent == null && (parent = {
        tab: {}
      });
      if (!(tab && (Array.isArray(tab) || typeof tab === 'object'))) {
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
          return v.id = id, v;
        });
      for (i$ = 0, to$ = list.length; i$ < to$; ++i$) {
        order = i$;
        item = list[order];
        import$((item.depth = depth, item.parent = parent, item), !v.name
          ? {
            name: item.id
          }
          : {});
        import$(item, !(v.order != null)
          ? {
            order: order
          }
          : {});
        tabo = this$._prepareTab(item);
        results$.push(traverse(item.child, (item.depth || 0) + 1, tabo));
      }
      return results$;
    };
    return traverse(this._tab);
  }
});
konfig.merge = function(des){
  var objs, res$, i$, to$, _, i;
  des == null && (des = {});
  res$ = [];
  for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
    res$.push(arguments[i$]);
  }
  objs = res$;
  _ = function(des, src){
    var ref$, dc, sc, k, v;
    des == null && (des = {});
    src == null && (src = {});
    ref$ = [des.child ? des.child : des, src.child ? src.child : src], dc = ref$[0], sc = ref$[1];
    for (k in sc) {
      v = sc[k];
      if (v.type || (dc[k] && dc[k].type)) {
        if (!dc[k]) {
          dc[k] = src[k];
        } else if (dc[k]) {
          import$(dc[k], src[k]);
        }
      } else {
        dc[k] = _(dc[k], sc[k]);
      }
    }
    return des;
  };
  for (i$ = 0, to$ = objs.length; i$ < to$; ++i$) {
    i = i$;
    des = _(des, JSON.parse(JSON.stringify(objs[i])));
  }
  return des;
};
konfig.append = function(){
  var cs, res$, i$, to$, ret, _, i, ref$, c1, c2;
  res$ = [];
  for (i$ = 0, to$ = arguments.length; i$ < to$; ++i$) {
    res$.push(arguments[i$]);
  }
  cs = res$;
  ret = {};
  _ = function(a, b){
    var k, v, results$ = [];
    for (k in b) {
      v = b[k];
      if (typeof v === 'object') {
        if (!typeof a[k] === 'object') {
          a[k] = {};
        }
        _(a[k], v);
      }
      results$.push(a[k] = v);
    }
    return results$;
  };
  for (i$ = cs.length - 2; i$ >= 0; --i$) {
    i = i$;
    ref$ = [JSON.parse(JSON.stringify(cs[i])), cs[i + 1]], c1 = ref$[0], c2 = ref$[1];
    _(c1, c2);
  }
  return c1;
};
konfig.version = 'main';
if (typeof module != 'undefined' && module !== null) {
  module.exports = konfig;
} else if (typeof window != 'undefined' && window !== null) {
  window.konfig = konfig;
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
konfig.bundle = (konfig.bundle || []).concat([{"name":"@plotdb/konfig","version":"main","path":"base","code":"<div><div class=\"d-flex\"><div class=\"flex-grow-1 d-flex align-items-center\"><div ld=\"name\"></div><div ld=\"hint\">?</div></div><plug name=\"ctrl\"></plug></div><plug name=\"config\"></plug><style type=\"text/css\">[ld=hint]{margin-left:.5em;width:1.2em;height:1.2em;border-radius:50%;background:rgba(0,0,0,0.1);font-size:10px;line-height:1.1em;text-align:center;cursor:pointer}</style><script type=\"@plotdb/block\">module.exports={pkg:{dependencies:[{name:\"@loadingio/vscroll\",version:\"main\",path:\"index.min.js\"},{name:\"@loadingio/debounce.js\",version:\"main\",path:\"index.min.js\"},{name:\"ldview\",version:\"main\",path:\"index.min.js\"},{name:\"ldcover\",version:\"main\",path:\"index.min.js\"},{name:\"ldcover\",version:\"main\",path:\"index.min.css\"},{name:\"ldloader\",version:\"main\",path:\"index.min.js\"},{name:\"ldloader\",version:\"main\",path:\"index.min.css\",global:true},{name:\"zmgr\",version:\"main\",path:\"index.min.js\"}]},init:function(n){var e,t,i,r,a,o,u,m,d,s,l=this;e=n.root,t=n.context,i=n.data,r=n.pubsub,a=n.t;this._meta=i;o=t.ldcover,u=t.ldloader,m=t.zmgr;d=new m;o.zmgr(d);u.zmgr(d);r.on(\"init\",function(n){var e;n==null&&(n={});l.itf=e={evtHandler:{},get:n.get||function(){},set:n.set||function(){},meta:n.meta||function(n){return l._meta=n},default:n[\"default\"]||function(){return l._meta[\"default\"]},object:n.object||function(n){return Promise.resolve(n)},render:function(){s.render();if(n.render){return n.render()}},on:function(n,t){var i=this;return(Array.isArray(n)?n:[n]).map(function(n){var e;return((e=i.evtHandler)[n]||(e[n]=[])).push(t)})},fire:function(n){var e,t,i,r,a,o,u,m=[];t=[];for(i=1,r=arguments.length;i<r;++i){t.push(arguments[i])}e=t;for(i=0,o=(a=this.evtHandler[n]||[]).length;i<o;++i){u=a[i];m.push(u.apply(this,e))}return m}};if(s){return s.render(\"hint\")}});r.on(\"event\",function(n){var e,t,i,r;t=[];for(i=1,r=arguments.length;i<r;++i){t.push(arguments[i])}e=t;return l.itf.fire.apply(l.itf,[n].concat(e))});if(!e){return}return s=new ldview({root:e,text:{name:function(){return a(l._meta.name||l._meta.id||\"\")}},handler:{hint:function(n){var e;e=n.node;return e.classList.toggle(\"d-none\",!l._meta.hint)}},action:{click:{hint:function(){return alert(a(l._meta.hint||\"no hint\"))}}}})},interface:function(){return this.itf}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"boolean","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[{name:\"ldview\",version:\"main\",path:\"index.min.js\"}]},init:function(t){var e,n,a,i,r,u,s;e=t.root,n=t.context,a=t.pubsub,i=t.data;r=n.ldview;u={default:i[\"default\"],state:i[\"default\"]||false};a.fire(\"init\",{get:function(){return u.state},set:function(t){u.state=!!t;return s.render(\"switch\")},default:function(){return u[\"default\"]},meta:function(t){return u[\"default\"]=t[\"default\"]}});return s=new r({root:e,action:{click:{switch:function(){u.state=!u.state;s.render(\"switch\");return a.fire(\"event\",\"change\",u.state)}}},handler:{switch:function(t){var e;e=t.node;return e.classList.toggle(\"on\",u.state)}}})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"button","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[],i18n:{\"zh-TW\":{config:\"設定\"}}},init:function(t){var e,n,a,u,r,o,i,d,f;e=t.root,n=t.context,a=t.data,u=t.pubsub,r=t.t;o=n.ldview,i=n.ldcolor;d={data:a[\"default\"],default:a[\"default\"]};u.fire(\"init\",{get:function(){return d.data},set:function(t){return d.data=t},default:function(){return d[\"default\"]},meta:function(t){return d.data=d[\"default\"]=t[\"default\"]}});return f=new o({root:e,action:{click:{button:function(){return Promise.resolve(a.cb(d.data)).then(function(t){if(d.data===t){return}return u.fire(\"event\",\"change\",d.data=t)})}}},text:{button:function(){return a.text||\"...\"}}})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"choice","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[]},init:function(e){var t,n,r,a,u,i,o=this;t=e.root,n=e.context,r=e.data,a=e.pubsub;this._meta=r;u=n.ldview;a.fire(\"init\",{get:function(){return i.get(\"select\").value},set:function(e){return i.get(\"select\").value=e},default:function(){return o._meta[\"default\"]},meta:function(e){return o._meta=e}});return i=new u({root:t,action:{change:{select:function(e){var t;t=e.node;return a.fire(\"event\",\"change\",t.value)}}},handler:{option:{list:function(){return o._meta.values},key:function(e){return e},init:function(e){var t,n;t=e.node,n=e.data;if(o._meta[\"default\"]===n){return t.setAttribute(\"selected\",\"selected\")}},handler:function(e){var t,n;t=e.node,n=e.data;t.setAttribute(\"value\",n);return t.textContent=n}}}})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"color","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[{name:\"ldcolor\",version:\"main\",path:\"index.min.js\",async:false},{name:\"@loadingio/ldcolorpicker\",version:\"main\",path:\"index.min.js\"},{name:\"@loadingio/ldcolorpicker\",version:\"main\",path:\"index.min.css\",global:true}]},init:function(e){var t,n,r,i,o,a,c,l,u=this;t=e.root,n=e.context,r=e.pubsub,i=e.data;o=n.ldview,a=n.ldcolor,c=n.ldcolorpicker;this._meta=i;this.render=function(){r.fire(\"render\");if(typeof l!=\"undefined\"&&l!==null){return l.render()}};this.set=function(e){this.c=e;if(!(e===\"currentColor\"||e===\"transparent\"||isNaN(a.hsl(e).h))){this.ldcp.setColor(e)}return this.render()};this.prepareDefault=function(e){var t;e==null&&(e={});this[\"default\"]=(t=e.data[\"default\"])===\"currentColor\"||t===\"transparent\"?e.data[\"default\"]:a.web(e.data[\"default\"]||this.ldcp.getColor());if(e.overwrite){return this.set(this[\"default\"])}};r.fire(\"init\",{get:function(){return u.c},set:function(e){return u.set(e)},default:function(){return u[\"default\"]},meta:function(e){u._meta=e;u.ldcp.setPalette(e.palette);if(e.idx!=null){u.ldcp.setIdx(e.idx)}return u.prepareDefault({overwrite:true,data:e})}});this.ldcp=new c(t.querySelector(\"[ld~=input]\"),{className:\"round shadow-sm round flat compact-palette no-button no-empty-color vertical\",palette:(i[\"default\"]?[i[\"default\"]]:[]).filter(function(e){return!(e===\"transparent\"||e===\"currentColor\")}).concat(i.palette||[\"#cc0505\",\"#f5b70f\",\"#9bcc31\",\"#089ccc\"]),context:i.context||\"random\",exclusive:i.exclusive!=null?i.exclusive:true});this.prepareDefault({overwrite:true,data:i});l=new o({root:t,action:{keyup:{input:function(e){var t,n,r;t=e.node,n=e.ctx,r=e.evt;if(r.keyCode===13){u.ldcp.setColor(t.value);return u.c=t.value}}},click:{default:function(e){var t,n;t=e.node,n=e.ctx;u.c=\"currentColor\";r.fire(\"event\",\"change\",u.c);return u.render()}}},handler:{preset:{list:function(){return u._meta.presets||[]},key:function(e){return e},view:{text:{\"@\":function(e){var t;t=e.ctx;return t}},action:{click:{\"@\":function(e){var t;t=e.ctx;u.c=t;r.fire(\"event\",\"change\",u.c);return u.render()}}}}},color:function(e){var t,n,r;t=e.node,n=e.ctx;r=a.web(u.c);if(t.nodeName.toLowerCase()===\"input\"){return t.value=isNaN(a.hsl(u.c).h)?u.c:r}else{return t.style.backgroundColor=r}}}});return this.ldcp.on(\"change\",function(e){u.c=a.web(e);r.fire(\"event\",\"change\",u.c);return u.render()})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"font","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[{name:\"@xlfont/load\",version:\"main\",path:\"index.min.js\"},{name:\"@xlfont/choose\",version:\"main\",path:\"index.min.js\"},{name:\"@xlfont/choose\",version:\"main\",path:\"index.min.css\",global:true}],i18n:{en:{default:\"Default\"},\"zh-TW\":{\"system default\":\"預設字型\"}}},init:function(n){var e,t,o,r,i,a,f,u,l,s,c,d;e=n.root,t=n.context,o=n.data,r=n.pubsub,i=n.t;a=t.ldview,f=t.ldcover,u=t.xfc;l={font:null};s=function(){if(typeof l._m[\"default\"]===\"string\"){return{name:l._m[\"default\"]}}else{return l._m[\"default\"]}};r.fire(\"init\",{get:function(){var n;if(!l.font){return null}return{name:(n=l.font).name,style:n.style,weight:n.weight}},set:function(n){l.font=!n?n:typeof n===\"string\"?{name:n}:{name:n.name,style:n.style,weight:n.weight};return d.render(\"font-name\")},default:function(){return s()},meta:function(n){return l._meta=n},object:function(n){return c.load(n)}});l._m=o||{};l.font=s();c=new u({root:!e?null:e.querySelector(\".ldcv\"),initRender:true,meta:\"https://xlfont.maketext.io/meta\",links:\"https://xlfont.maketext.io/links\"});c.init();if(!e){return}c.on(\"choose\",function(n){return l.ldcv.set(n)});return d=new a({root:e,init:{ldcv:function(n){var e;e=n.node;l.ldcv=new f({root:e,inPlace:false});return l.ldcv.on(\"toggle.on\",function(){return debounce(50).then(function(){return c.render()})})}},action:{click:{system:function(n){var e,t;e=n.node;l.font=t=null;d.render(\"font-name\");return r.fire(\"event\",\"change\",t)},button:function(n){var e;e=n.node;return l.ldcv.get().then(function(n){l.font=n?{name:n.name,style:n.style,weight:n.weight}:null;d.render(\"font-name\");return r.fire(\"event\",\"change\",l.font)})}}},handler:{\"font-name\":function(n){var t,e;t=n.node;e=!l.font?i(\"default\"):l.font.name||i(\"default\");if(e.length>10){e=e.substring(0,10)+\"...\"}t.innerText=e;return Promise.resolve(l.font?c.load(l.font):l.font).then(function(n){var e;return t.setAttribute(\"class\",(e=n&&n.className)?e:\"\")})}}})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"number","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[{name:\"ldslider\",version:\"main\",path:\"index.min.css\"},{name:\"ldslider\",version:\"main\",path:\"index.min.js\"}]},init:function(t){var e,n,r,i,o,l,u,a,f,d=this;e=t.root,n=t.context,r=t.data,i=t.pubsub;o=n.ldview,l=n.ldslider;u={};this._meta={};a=function(t){if(t.from!=null){console.warn(\"[@plotdb/konfig] ctrl should use `default` for default value.\\nplease update your config to comply with it.\")}if(t[\"default\"]!=null){if(typeof t[\"default\"]===\"object\"){import$(t,t[\"default\"])}else if(typeof t[\"default\"]===\"number\"){t.from=t[\"default\"]}}return d._meta=JSON.parse(JSON.stringify(t))};i.fire(\"init\",{get:function(){return u.ldrs.get()},set:function(t){return u.ldrs.set(t)},default:function(){return d._meta[\"default\"]},meta:function(t){a(t);return u.ldrs.setConfig(Object.fromEntries([\"min\",\"max\",\"step\",\"from\",\"to\",\"exp\",\"limitMax\",\"range\",\"label\"].map(function(t){return[t,d._meta[t]]}).filter(function(t){return t[1]!=null})))},render:function(){return u.ldrs.update()}});a(r);return f=new o({root:e,action:{click:{switch:function(){return u.ldrs.edit()}}},init:{ldrs:function(t){var e;e=t.node;u.root=e;u.ldrs=new l(import$({root:e},Object.fromEntries([\"min\",\"max\",\"step\",\"from\",\"to\",\"exp\",\"limitMax\",\"range\",\"label\"].map(function(t){return[t,d._meta[t]]}).filter(function(t){return t[1]!=null}))));return u.ldrs.on(\"change\",function(t){return i.fire(\"event\",\"change\",t)})}}})}};function import$(t,e){var n={}.hasOwnProperty;for(var r in e)if(n.call(e,r))t[r]=e[r];return t}</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"palette","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[{name:\"ldbutton\",version:\"main\",path:\"index.min.css\",global:true},{name:\"ldcolor\",version:\"main\",path:\"index.min.js\",async:false},{name:\"ldslider\",version:\"main\",path:\"index.min.js\",async:false},{name:\"ldslider\",version:\"main\",path:\"index.min.css\",global:true},{name:\"@loadingio/ldcolorpicker\",version:\"main\",path:\"index.min.js\",async:false},{name:\"@loadingio/ldcolorpicker\",version:\"main\",path:\"index.min.css\"},{name:\"@loadingio/vscroll\",version:\"main\",path:\"index.min.js\"},{name:\"ldpalettepicker\",version:\"main\",path:\"index.min.css\",global:true},{name:\"ldpalettepicker\",version:\"main\",path:\"index.min.js\"}]},init:function(e){var n,t,a,r,i,l,o,d,s,p,u,c;n=e.root,t=e.context,a=e.pubsub,r=e.data,i=e.i18n,l=e.manager;o=t.ldview,d=t.ldcolor,s=t.ldpp,p=t.ldcover;u={default:r[\"default\"]||s.defaultPalette,pal:r[\"default\"]||s.defaultPalette};a.fire(\"init\",{get:function(){return u.pal},set:function(e){u.pal=e;return c.render()},default:function(){return u[\"default\"]},meta:function(e){return u[\"default\"]=e[\"default\"]||s.defaultPalette}});n=ld$.find(n,\"[plug=config]\",0);c=new o({root:n,action:{click:{ldp:function(e){var n,t;n=e.node;t=n.getAttribute(\"data-action\")||\"edit\";return Promise.resolve().then(function(){var e,n;if(u.ldpp){return}e=Array.isArray(r.palettes)?r.palettes:typeof r.palettes===\"string\"?s.get(r.palettes):null;n=e?Promise.resolve(e):l.rescope.load([{name:\"ldpalettepicker\",version:\"main\",path:\"index.min.js\",async:false},{name:\"ldpalettepicker\",version:\"main\",path:\"all.palettes.js\"}]).then(function(e){var n;n=e.ldpp;return n.get(\"all\")});return n.then(function(e){return u.ldpp=new s({root:c.get(\"ldcv\"),ldcv:{inPlace:false},useClusterizejs:true,i18n:i,palette:r.palette,palettes:e,useVscroll:true})})}).then(function(){u.ldpp.edit(u.pal);if(t!==\"edit\"){u.ldpp.tab(\"view\")}return u.ldpp.get()}).then(function(e){if(!e){return}u.pal=e;c.render(\"color\");return a.fire(\"event\",\"change\",u.pal)})}}},handler:{color:{list:function(){var e;return((e=u.pal||(u.pal={})).colors||(e.colors=[])).map(function(e,n){return import$({_idx:n},d.hsl(e))})},key:function(e){return e._idx},handler:function(e){var n,t;n=e.node,t=e.data;return n.style.backgroundColor=d.web(t)}}}});return c.render()}};function import$(e,n){var t={}.hasOwnProperty;for(var a in n)if(t.call(n,a))e[a]=n[a];return e}</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"paragraph","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[]},init:function(t){var e,n,r,a,i,u,o,d;e=t.root,n=t.context,r=t.data,a=t.pubsub;i={default:r[\"default\"]||\"\",data:r[\"default\"]||\"\"};u=n.ldview,o=n.ldcover;a.fire(\"init\",{get:function(){return i.data||\"\"},set:function(t){i.data=t||\"\";return d.render()},default:function(){return i[\"default\"]},meta:function(t){return i[\"default\"]=t[\"default\"]}});return d=new u({root:e,init:{ldcv:function(t){var e;e=t.node;return i.ldcv=new o({root:e})}},handler:{panel:function(t){var e;e=t.node},input:function(t){var e;e=t.node;return e.value=i.data||\"\"},textarea:function(t){var e;e=t.node;return e.value=i.data||\"\"}},action:{click:{input:function(t){var e,n,r;e=t.node;n=d.get(\"input\").getBoundingClientRect();r=d.get(\"panel\").getBoundingClientRect();import$(d.get(\"panel\").style,{width:n.width+\"px\",left:n.left+\"px\",top:n.top+\"px\"});return i.ldcv.get().then(function(t){var e;if(t!==\"ok\"){return}e=d.get(\"textarea\").value;if(i.data!==e){a.fire(\"event\",\"change\",e)}i.data=e;return d.render()})}}}})}};function import$(t,e){var n={}.hasOwnProperty;for(var r in e)if(n.call(e,r))t[r]=e[r];return t}</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"popup","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[],i18n:{\"zh-TW\":{config:\"設定\"}}},init:function(t){var n,e,r,o,u,i,a,p,c,f,d;n=t.root,e=t.context,r=t.data,o=t.pubsub,u=t.t;i={};a=function(t){var n;if(!t){return null}else if(n=t.data){return n}else{return t}};p=function(t){var n;i.text=(n=t&&t.text)?n:typeof t===\"string\"?t+\"\":u(\"config\");return d.render(\"button\")};c=e.ldview,f=e.ldcolor;o.fire(\"init\",{get:function(){return r.popup.data()},set:function(t){r.popup.data(t);return p(r.popup.data())}});return d=new c({root:n,action:{click:{button:function(){return r.popup.get().then(function(t){o.fire(\"event\",\"change\",a(t));return p(t)})}}},text:{button:function(){var t;if(t=i.text){return t}else{return u(\"config\")}}}})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"quantity","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[{name:\"ldslider\",version:\"main\",path:\"index.min.css\"},{name:\"ldslider\",version:\"main\",path:\"index.min.js\"}],i18n:{en:{unit:\"Unit\"},\"zh-TW\":{unit:\"單位\"}}},init:function(n){var t,e,i,r,u,a,o,l,d,f,s,c=this;t=n.root,e=n.context,i=n.data,r=n.pubsub;u=e.ldview,a=e.ldslider;o={};this._meta={};l=function(n){var t;n==null&&(n={});t=o.ldrs.get()+\"\"+o.unit;if(!n.init&&t!==o.v){r.fire(\"event\",\"change\",t)}return o.v=t};d=function(n){var t,e;n==null&&(n={});t=import$({},n.unit);o.unit=t.name;if(t.from!=null){console.warn(\"[@plotdb/konfig] ctrl should use `default` for default value.\\nplease update your config to comply with it.\")}if(t[\"default\"]!=null){t.from=t[\"default\"]}o.ldrs.setConfig((e=Object.fromEntries([\"min\",\"max\",\"step\",\"from\",\"to\",\"exp\",\"limitMax\",\"range\",\"label\"].map(function(n){return[n,t[n]]}).filter(function(n){return n[1]!=null})),e.unit=t.name||\"\",e));l({init:n.init});return s.render()};f=function(n){var t;n==null&&(n={});c._meta=t=JSON.parse(JSON.stringify(n.meta||{}));return d({unit:t.units[0],init:n.init})};r.fire(\"init\",{get:function(){return o.ldrs.get()+\"\"+o.unit},set:function(n){var t;t=/^(\\d+(?:\\.(?:\\d+))?)(\\D*)/.exec(n+\"\");if(!t){t=/^(\\d+(?:\\.(?:\\d+))?)(\\D*)/.exec(this[\"default\"]()+\"\")}if(!t){t=[0,0,this._meta.units[0]]}o.ldrs.set(+t[1]);o.unit=t[2]||o.unit||this._meta.units[0];return s.render()},default:function(){return c._meta[\"default\"]},meta:function(n){return f({meta:n})},render:function(){return o.ldrs.update()}});s=new u({root:t,initRender:false,action:{click:{switch:function(){return o.ldrs.edit()}}},init:{ldrs:function(n){var t;t=n.node;o.root=t;o.ldrs=new a({root:t});return o.ldrs.on(\"change\",function(){return l()})}},text:{picked:function(){return o.unit}},handler:{unit:{list:function(){return c._meta.units},key:function(n){return n.name},action:{click:function(n){var t;t=n.data;return d({unit:t})}},text:function(n){var t;t=n.data;return t.name}}}});return s.init().then(function(){return f({meta:i,init:true})})}};function import$(n,t){var e={}.hasOwnProperty;for(var i in t)if(e.call(t,i))n[i]=t[i];return n}</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"text","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[]},init:function(e){var n,t,u,a,r,i,o,c=this;n=e.root,t=e.context,u=e.data,a=e.pubsub;r=t.ldview;i=function(e){c._meta=e;return c._values=c._meta.values||[]};a.fire(\"init\",{get:function(){return o.get(\"input\").value||\"\"},set:function(e){return o.get(\"input\").value=e||\"\"},default:function(){return c._meta[\"default\"]||\"\"},meta:function(e){return i(e)}});return o=new r({root:n,init:{input:function(e){var n;n=e.node;return n.value=u[\"default\"]||\"\"}},handler:{preset:{list:function(){return c._values||[]},key:function(e){return e.value||e.name||e},handler:function(e){var n,t;n=e.node,t=e.data;return n.textContent=t.name||t.value||t},action:{click:function(e){var n,t,u;n=e.node,t=e.data;o.get(\"input\").value=u=t.value||t;return a.fire(\"event\",\"change\",u)}}}},action:{input:{input:function(e){var n;n=e.node;return a.fire(\"event\",\"change\",n.value)}},change:{input:function(e){var n;n=e.node;return a.fire(\"event\",\"change\",n.value)}}}})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"upload","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\"},dependencies:[{name:\"ldfile\"}]},init:function(t){var e,n,i,u,r,o,a,f=this;e=t.root,n=t.context,i=t.data,u=t.pubsub;r=n.ldview,o=n.ldfile;this._meta=i;u.fire(\"init\",{get:function(){return a.get(\"input\").value||\"\"},set:function(t){return a.get(\"input\").value=t||\"\"},default:function(){return[]},meta:function(t){return f._meta=t}});return a=new r({root:e,init:{input:function(t){var e;e=t.node;if(f._meta.multiple){return e.setAttribute(\"multiple\",true)}}},action:{change:{input:function(t){var i,e,r;i=t.node;e=function(){var t,e,n=[];for(t=0,e=i.files.length;t<e;++t){r=t;n.push(i.files[r])}return n}().map(function(t){return o.fromFile(t,\"dataurl\").then(function(t){return t.result})});return Promise.all(e).then(function(t){return u.fire(\"event\",\"change\",t)})}}}})}};</script></div>"}]);
})();
