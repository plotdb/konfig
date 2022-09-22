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
              return !(it.tab.parent.id || ctx.tab.id) || (it.tab.parent && ctx.tab && it.tab.parent.id === ctx.tab.id);
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
  meta: function(opt){
    var meta, tab, config;
    opt == null && (opt = {});
    meta = opt.meta, tab = opt.tab, config = opt.config;
    this._meta = {};
    this._tab = {};
    if (!(meta != null) || typeof meta.type === 'string') {
      this._meta = opt;
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
  get: function(){
    return JSON.parse(JSON.stringify(this._val));
  },
  set: function(nv, o){
    var traverse;
    o == null && (o = {});
    nv = JSON.parse(JSON.stringify(nv));
    this.render();
    traverse = function(meta, val, nval, ctrl, pid){
      var ctrls, id, v, results$ = [];
      val == null && (val = {});
      nval == null && (nval = {});
      ctrl == null && (ctrl = {});
      ctrls = meta.child ? meta.child : meta;
      for (id in ctrls) {
        v = ctrls[id];
        if (v.type) {
          if (val[id] !== nval[id] && !(o.append && !(nval[id] != null))) {
            val[id] = nval[id];
            results$.push(ctrl[id].itf.set(val[id]));
          }
        } else {
          results$.push(traverse(v, val[id] || (val[id] = {}), nval[id] || (nval[id] = {}), ctrl[id] || (ctrl[id] = {}), id));
        }
      }
      return results$;
    };
    return traverse(this._meta, this._val, nv, this._ctrlobj, null);
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
      ref$ = ['', meta.type, "master", ''], ns = ref$[0], name = ref$[1], version = ref$[2], path = ref$[3];
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
      var root;
      root = document.createElement('div');
      if (!(meta.tab != null)) {
        meta.tab = 'default';
      }
      if (!this$._tabobj[meta.tab]) {
        this$._prepareTab({
          id: meta.tab,
          name: meta.tab,
          depth: 0,
          parent: {}
        });
      }
      this$._ctrllist.push(ctrl[id] = {
        block: b,
        meta: meta,
        root: root,
        key: Math.random().toString(36).substring(2)
      });
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
      return item.on('change', function(it){
        val[id] = it;
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
    traverse = function(meta, val, ctrl, pid){
      var ctrls, tab, id, v, results$ = [];
      val == null && (val = {});
      ctrl == null && (ctrl = {});
      if (!(meta && typeof meta === 'object')) {
        return;
      }
      ctrls = meta.child ? meta.child : meta;
      tab = meta.child ? meta.tab : null;
      if (!tab && this$.autotab && pid) {
        tab = pid;
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
          promises.push(this$._prepareCtrl(v, val, ctrl));
          continue;
        }
        results$.push(traverse(v, val[id] || (val[id] = {}), ctrl[id] || (ctrl[id] = {}), id));
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
    }
    if (clear || !this._ctrlobj) {
      this._ctrlobj = {};
    }
    if (clear || !this._ctrllist) {
      this._ctrllist = [];
    }
    traverse(this._meta, this._val, this._ctrlobj, null);
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
      var list, id, v, i$, to$, order, item, results$ = [];
      depth == null && (depth = 0);
      parent == null && (parent = {});
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
        this$._prepareTab(item);
        results$.push(traverse(item.child, (item.depth || 0) + 1, item));
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
konfig.bundle = (konfig.bundle || []).concat([{"name":"@plotdb/konfig.widget.default","version":"master","path":"base","code":"<div><div class=\"d-flex\"><div class=\"flex-grow-1 d-flex align-items-center\"><div ld=\"name\"></div><div ld=\"hint\">?</div></div><plug name=\"ctrl\"></plug></div><plug name=\"config\"></plug><style type=\"text/css\">[ld=hint]{margin-left:.5em;width:1.2em;height:1.2em;border-radius:50%;background:rgba(0,0,0,0.1);font-size:10px;line-height:1.1em;text-align:center;cursor:pointer}</style><script type=\"@plotdb/block\">module.exports={pkg:{dependencies:[{name:\"@loadingio/vscroll\",version:\"main\",path:\"index.min.js\"},{name:\"@loadingio/debounce.js\",version:\"main\",path:\"index.min.js\"},{name:\"ldview\",version:\"main\",path:\"index.min.js\"},{name:\"ldcover\",version:\"main\",path:\"index.min.js\"},{name:\"ldcover\",version:\"main\",path:\"index.min.css\"},{name:\"ldloader\",version:\"main\",path:\"index.min.js\"},{name:\"ldloader\",version:\"main\",path:\"index.min.css\",global:true},{name:\"zmgr\",version:\"main\",path:\"index.min.js\"}]},init:function(n){var e,t,i,r,a,o,d,m,u,s,l=this;e=n.root,t=n.context,i=n.data,r=n.pubsub,a=n.t;this._meta=i;o=t.ldcover,d=t.ldloader,m=t.zmgr;u=new m;o.zmgr(u);d.zmgr(u);r.on(\"init\",function(n){var e;n==null&&(n={});l.itf=e={evtHandler:{},get:n.get||function(){},set:n.set||function(){},meta:n.meta||function(n){return l._meta=n},default:n[\"default\"]||function(){return l._meta[\"default\"]},render:function(){s.render();if(n.render){return n.render()}},on:function(n,t){var i=this;return(Array.isArray(n)?n:[n]).map(function(n){var e;return((e=i.evtHandler)[n]||(e[n]=[])).push(t)})},fire:function(n){var e,t,i,r,a,o,d,m=[];t=[];for(i=1,r=arguments.length;i<r;++i){t.push(arguments[i])}e=t;for(i=0,o=(a=this.evtHandler[n]||[]).length;i<o;++i){d=a[i];m.push(d.apply(this,e))}return m}};return s.render(\"hint\")});r.on(\"event\",function(n){var e,t,i,r;t=[];for(i=1,r=arguments.length;i<r;++i){t.push(arguments[i])}e=t;return l.itf.fire.apply(l.itf,[n].concat(e))});return s=new ldview({root:e,text:{name:function(){return a(l._meta.name||l._meta.id||\"\")}},handler:{hint:function(n){var e;e=n.node;return e.classList.toggle(\"d-none\",!l._meta.hint)}},action:{click:{hint:function(){return alert(a(l._meta.hint||\"no hint\"))}}}})},interface:function(){return this.itf}};</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"boolean","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[{name:\"ldview\",version:\"main\",path:\"index.min.js\"}]},init:function(t){var e,n,a,i,r,u,s;e=t.root,n=t.context,a=t.pubsub,i=t.data;r=n.ldview;u={default:i[\"default\"],state:i[\"default\"]||false};a.fire(\"init\",{get:function(){return u.state},set:function(t){u.state=!!t;return s.render(\"switch\")},default:function(){return u[\"default\"]},meta:function(t){return u[\"default\"]=t[\"default\"]}});return s=new r({root:e,action:{click:{switch:function(){u.state=!u.state;s.render(\"switch\");return a.fire(\"event\",\"change\",u.state)}}},handler:{switch:function(t){var e;e=t.node;return e.classList.toggle(\"on\",u.state)}}})}};</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"button","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[],i18n:{\"zh-TW\":{config:\"設定\"}}},init:function(t){var e,n,a,u,r,o,i,d,f;e=t.root,n=t.context,a=t.data,u=t.pubsub,r=t.t;o=n.ldview,i=n.ldcolor;d={data:a[\"default\"],default:a[\"default\"]};u.fire(\"init\",{get:function(){return d.data},set:function(t){return d.data=t},default:function(){return d[\"default\"]},meta:function(t){return d.data=d[\"default\"]=t[\"default\"]}});return f=new o({root:e,action:{click:{button:function(){return Promise.resolve(a.cb(d.data)).then(function(t){if(d.data===t){return}return u.fire(\"event\",\"change\",d.data=t)})}}},text:{button:function(){return a.text||\"...\"}}})}};</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"choice","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[]},init:function(e){var t,n,r,a,u,i,o=this;t=e.root,n=e.context,r=e.data,a=e.pubsub;this._meta=r;u=n.ldview;a.fire(\"init\",{get:function(){return i.get(\"select\").value},set:function(e){return i.get(\"select\").value=e},default:function(){return o._meta[\"default\"]},meta:function(e){return o._meta=e}});return i=new u({root:t,action:{change:{select:function(e){var t;t=e.node;return a.fire(\"event\",\"change\",t.value)}}},handler:{option:{list:function(){return o._meta.values},key:function(e){return e},init:function(e){var t,n;t=e.node,n=e.data;if(o._meta[\"default\"]===n){return t.setAttribute(\"selected\",\"selected\")}},handler:function(e){var t,n;t=e.node,n=e.data;t.setAttribute(\"value\",n);return t.textContent=n}}}})}};</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"color","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[{name:\"ldcolor\",version:\"main\",path:\"index.min.js\",async:false},{name:\"@loadingio/ldcolorpicker\",version:\"main\",path:\"index.min.js\"},{name:\"@loadingio/ldcolorpicker\",version:\"main\",path:\"index.min.css\",global:true}]},init:function(e){var t,o,n,l,r,c,a,i,d=this;t=e.root,o=e.context,n=e.pubsub,l=e.data;r=o.ldview,c=o.ldcolor,a=o.ldcolorpicker;n.fire(\"init\",{get:function(){if(d.ldcp){return c.web(d.ldcp.getColor())}},set:function(e){return d.ldcp.setColor(e)},default:function(){return d[\"default\"]},meta:function(e){d.ldcp.setPalette(e.palette);if(e.idx!=null){d.ldcp.setIdx(e.idx)}return d[\"default\"]=c.web(e[\"default\"]||d.ldcp.getColor())}});this.ldcp=new a(t,{className:\"round shadow-sm round flat compact-palette no-button no-empty-color vertical\",palette:(l[\"default\"]?[l[\"default\"]]:[]).concat(l.palette||[\"#cc0505\",\"#f5b70f\",\"#9bcc31\",\"#089ccc\"]),context:l.context||\"random\",exclusive:l.exclusive!=null?l.exclusive:true});this[\"default\"]=c.web(l[\"default\"]||this.ldcp.getColor());i=new r({ctx:{color:c.web(this.ldcp.getColor())},root:t,handler:{color:function(e){var t,o;t=e.node,o=e.ctx;if(t.nodeName.toLowerCase()===\"input\"){return t.value=o.color}else{return t.style.backgroundColor=o.color}}}});return this.ldcp.on(\"change\",function(e){var t;t=c.web(e);n.fire(\"event\",\"change\",t);i.setCtx({color:t});return i.render()})}};</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"font","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[{name:\"@xlfont/load\",version:\"main\",path:\"index.min.js\"},{name:\"@xlfont/choose\",version:\"main\",path:\"index.min.js\"},{name:\"@xlfont/choose\",version:\"main\",path:\"index.min.css\",global:true}]},init:function(n){var e,t,o,r,i,u,a,l,f,c;e=n.root,t=n.context,o=n.data,r=n.pubsub;i=t.ldview,u=t.ldcover,a=t.xfc;r.fire(\"init\",{get:function(){var n;if(l.font){return{name:(n=l.font).name,style:n.style,weight:n.weight}}else if(typeof o[\"default\"]===\"string\"){return{name:o[\"default\"]}}else{return o[\"default\"]}},set:function(n){l.font=n;return c.render(\"button\")}});l={font:null};f=new a({root:e.querySelector(\".ldcv\"),initRender:true,meta:\"https://xlfont.maketext.io/meta\",links:\"https://xlfont.maketext.io/links\"});f.init();f.on(\"choose\",function(n){return l.ldcv.set(n)});return c=new i({root:e,init:{ldcv:function(n){var e;e=n.node;l.ldcv=new u({root:e,inPlace:false});return l.ldcv.on(\"toggle.on\",function(){return debounce(50).then(function(){return f.render()})})}},action:{click:{button:function(n){var e;e=n.node;return l.ldcv.get().then(function(n){l.font=n;c.render(\"button\");return r.fire(\"event\",\"change\",n)})}}},text:{button:function(n){var e;e=n.node;if(!l.font){return\"...\"}else{return l.font.name||\"...\"}}}})}};</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"number","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[{name:\"ldslider\",version:\"main\",path:\"index.min.css\"},{name:\"ldslider\",version:\"main\",path:\"index.min.js\"}]},init:function(t){var e,n,r,i,o,l,u,a,f,d=this;e=t.root,n=t.context,r=t.data,i=t.pubsub;o=n.ldview,l=n.ldslider;u={};this._meta={};a=function(t){if(t.from!=null){console.warn(\"[@plotdb/konfig] ctrl should use `default` for default value.\\nplease update your config to comply with it.\")}if(t[\"default\"]!=null){if(typeof t[\"default\"]===\"object\"){import$(t,t[\"default\"])}else if(typeof t[\"default\"]===\"number\"){t.from=t[\"default\"]}}return d._meta=JSON.parse(JSON.stringify(t))};i.fire(\"init\",{get:function(){return u.ldrs.get()},set:function(t){return u.ldrs.set(t)},default:function(){return d._meta[\"default\"]},meta:function(t){a(t);return u.ldrs.setConfig(Object.fromEntries([\"min\",\"max\",\"step\",\"from\",\"to\",\"exp\",\"limitMax\",\"range\",\"label\"].map(function(t){return[t,d._meta[t]]}).filter(function(t){return t[1]!=null})))},render:function(){return u.ldrs.update()}});a(r);return f=new o({root:e,action:{click:{switch:function(){return u.ldrs.edit()}}},init:{ldrs:function(t){var e;e=t.node;u.root=e;u.ldrs=new l(import$({root:e},Object.fromEntries([\"min\",\"max\",\"step\",\"from\",\"to\",\"exp\",\"limitMax\",\"range\",\"label\"].map(function(t){return[t,d._meta[t]]}).filter(function(t){return t[1]!=null}))));return u.ldrs.on(\"change\",function(t){return i.fire(\"event\",\"change\",t)})}}})}};function import$(t,e){var n={}.hasOwnProperty;for(var r in e)if(n.call(e,r))t[r]=e[r];return t}</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"palette","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[{name:\"ldbutton\",version:\"main\",path:\"index.min.css\",global:true},{name:\"ldcolor\",version:\"main\",path:\"index.min.js\",async:false},{name:\"ldslider\",version:\"main\",path:\"index.min.js\",async:false},{name:\"ldslider\",version:\"main\",path:\"index.min.css\",global:true},{name:\"@loadingio/ldcolorpicker\",version:\"main\",path:\"index.min.js\",async:false},{name:\"@loadingio/ldcolorpicker\",version:\"main\",path:\"index.min.css\"},{name:\"@loadingio/vscroll\",version:\"main\",path:\"index.min.js\"},{name:\"ldpalettepicker\",version:\"main\",path:\"index.min.css\",global:true},{name:\"ldpalettepicker\",version:\"main\",path:\"index.min.js\"}]},init:function(e){var n,t,a,r,l,i,o,s,d,p,u,c;n=e.root,t=e.context,a=e.pubsub,r=e.data,l=e.i18n,i=e.manager;o=t.ldview,s=t.ldcolor,d=t.ldpp,p=t.ldcover;u={default:r[\"default\"]||d.defaultPalette,pal:r[\"default\"]||d.defaultPalette};a.fire(\"init\",{get:function(){return u.pal},set:function(e){u.pal=e;return c.render()},default:function(){return u[\"default\"]},meta:function(e){return u[\"default\"]=e[\"default\"]||d.defaultPalette}});n=ld$.find(n,\"[plug=config]\",0);c=new o({root:n,action:{click:{ldp:function(){return Promise.resolve().then(function(){var e,n;if(u.ldpp){return}e=Array.isArray(r.palettes)?r.palettes:typeof r.palettes===\"string\"?d.get(r.palettes):null;n=e?Promise.resolve(e):i.rescope.load([{name:\"ldpalettepicker\",version:\"main\",path:\"index.min.js\",async:false},{name:\"ldpalettepicker\",version:\"main\",path:\"all.palettes.js\"}]).then(function(e){var n;n=e.ldpp;return n.get(\"all\")});return n.then(function(e){return u.ldpp=new d({root:c.get(\"ldcv\"),ldcv:{inPlace:false},useClusterizejs:true,i18n:l,palette:r.palette,palettes:e,useVscroll:true})})}).then(function(){return u.ldpp.get()}).then(function(e){if(!e){return}u.pal=e;c.render(\"color\");return a.fire(\"event\",\"change\",u.pal)})}}},handler:{color:{list:function(){var e;return((e=u.pal||(u.pal={})).colors||(e.colors=[])).map(function(e,n){return import$({_idx:n},s.hsl(e))})},key:function(e){return e._idx},handler:function(e){var n,t;n=e.node,t=e.data;return n.style.backgroundColor=s.web(t)}}}});return c.render()}};function import$(e,n){var t={}.hasOwnProperty;for(var a in n)if(t.call(n,a))e[a]=n[a];return e}</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"paragraph","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[]},init:function(t){var e,n,r,a,u,i,o,d;e=t.root,n=t.context,r=t.data,a=t.pubsub;u={default:r[\"default\"]||\"\",data:r[\"default\"]||\"\"};i=n.ldview,o=n.ldcover;a.fire(\"init\",{get:function(){return u.data||\"\"},set:function(t){u.data=t||\"\";return d.render()},default:function(){return u[\"default\"]},meta:function(t){return u[\"default\"]=t[\"default\"]}});return d=new i({root:e,init:{ldcv:function(t){var e;e=t.node;return u.ldcv=new o({root:e})}},handler:{panel:function(t){var e;e=t.node},input:function(t){var e;e=t.node;return e.value=u.data||\"\"},textarea:function(t){var e;e=t.node;return e.value=u.data||\"\"}},action:{click:{input:function(t){var e,n,r;e=t.node;n=d.get(\"input\").getBoundingClientRect();r=d.get(\"panel\").getBoundingClientRect();import$(d.get(\"panel\").style,{width:n.width+\"px\",left:n.left+\"px\",top:n.top+\"px\"});return u.ldcv.get().then(function(t){var e;if(t!==\"ok\"){return}e=d.get(\"textarea\").value;if(u.data!==e){a.fire(\"event\",\"change\",e)}u.data=e;return d.render()})}}}})}};function import$(t,e){var n={}.hasOwnProperty;for(var r in e)if(n.call(e,r))t[r]=e[r];return t}</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"popup","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[],i18n:{\"zh-TW\":{config:\"設定\"}}},init:function(t){var n,e,r,o,u,i,a,f,p,c,d;n=t.root,e=t.context,r=t.data,o=t.pubsub,u=t.t;i={};a=function(t){var n;if(!t){return null}else if(n=t.data){return n}else{return t}};f=function(t){var n;i.text=(n=t&&t.text)?n:typeof t===\"string\"?t+\"\":u(\"config\");return d.render(\"button\")};p=e.ldview,c=e.ldcolor;o.fire(\"init\",{get:function(){return r.popup.data()},set:function(t){r.popup.data(t);return f(r.popup.data())}});return d=new p({root:n,action:{click:{button:function(){return r.popup.get().then(function(t){o.fire(\"event\",\"change\",a(t));return f(t)})}}},text:{button:function(){var t;if(t=i.text){return t}else{return u(\"config\")}}}})}};</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"text","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[]},init:function(e){var t,n,u,i,r,a,o=this;t=e.root,n=e.context,u=e.data,i=e.pubsub;r=n.ldview;this._meta=u;i.fire(\"init\",{get:function(){return a.get(\"input\").value||\"\"},set:function(e){return a.get(\"input\").value=e||\"\"},default:function(){return o._meta[\"default\"]||\"\"},meta:function(e){return o._meta=e}});return a=new r({root:t,init:{input:function(e){var t;t=e.node;return t.value=u[\"default\"]||\"\"}},action:{input:{input:function(e){var t;t=e.node;return i.fire(\"event\",\"change\",t.value)}},change:{input:function(e){var t;t=e.node;return i.fire(\"event\",\"change\",t.value)}}}})}};</script></div>"},{"name":"@plotdb/konfig.widget.default","version":"master","path":"upload","code":"<div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig.widget.default\",version:\"master\",path:\"base\"},dependencies:[]},init:function(t){var e,n,i,u,r,a,o=this;e=t.root,n=t.context,i=t.data,u=t.pubsub;r=n.ldview;this._meta=i;u.fire(\"init\",{get:function(){return a.get(\"input\").value||\"\"},set:function(t){return a.get(\"input\").value=t||\"\"},default:function(){return[]},meta:function(t){return o._meta=t}});return a=new r({root:e,init:{input:function(t){var e;e=t.node;if(o._meta.multiple){return e.setAttribute(\"multiple\",true)}}},action:{change:{input:function(t){var e;e=t.node;return u.fire(\"event\",\"change\",e.files)}}}})}};</script></div>"}]);
})();
