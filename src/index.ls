konfig = (opt={}) ->
  @root = if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
  @opt = opt
  @evt-handler = {}
  @use-bundle = if (opt.use-bundle?) => opt.use-bundle else true
  @view = opt.view
  @autotab = (opt.autotab or false)
  @_ctrlobj = {}
  @_ctrllist = []
  @_tabobj = {}
  @_tablist = []
  @_template = null # for recursive view, or views with template
  @_meta = opt.meta or {}
  @_tab = opt.tab or {}
  @_val = {}
  @_obj = {}
  @_objps = []
  # meta can be updated anytime. we should always check if
  # building is in progress for some critical action such as `obj()`.
  @ensure-built = proxise ~> return if @ensure-built.running == true => null else Promise.resolve!
  @typemap = opt.typemap or null
  @mgr = @mgr-chain = new block.manager registry: ({name, version, path}) ->
    throw new Error("@plotdb/konfig: #name@#version/#path is not supported")
  if opt.manager =>
    @mgr = opt.manager
    @mgr.chain @mgr-chain
  @init = proxise.once (~> @_init!), (~> @_val)
  @_update-debounced = debounce 150, (n, v) ~> @_update n, v
  @do-debounce = !(opt.debounce?) or opt.debounce
  @update = (n,v) ~>
    if @do-debounce => @_update-debounced n, v
    else @_update n, v
  @

konfig.views =
  simple: ->
    new ldview do
      root: @root
      init-render: false
      handler:
        ctrl:
          list: ~> @_ctrllist.filter -> !it.meta.hidden
          key: -> it.key
          init: ({node, data}) ~> node.appendChild data.root
          handler: ({node, data}) ~> if !data.root.parentNode => node.appendChild data.root
  default: ->
    new ldview do
      root: @root
      init-render: false
      handler:
        tab:
          list: ~>
            @_tablist.sort (a,b) -> b.tab.order - a.tab.order
            @_tablist
          key: -> it.key
          view:
            text: name: ({ctx}) -> return ctx.tab.id
            handler:
              ctrl:
                list: ({ctx}) ~>
                  @_ctrllist.filter -> it.meta.tab == ctx.tab.id and !it.meta.hidden
                key: -> it.key
                init: ({node, data}) ~> node.appendChild data.root
                handler: ({node, data}) ~>
                  if !data.root.parentNode => node.appendChild data.root
                  data.itf.render!
  recurse: ->
    if @_template => template = @_template
    else
      template = ld$.find(@root, '[ld=template]', 0)
      template.parentNode.removeChild template
      template.removeAttribute \ld-scope
      @_template = template
    template = template.cloneNode true
    new ldview ({ctx: {tab: id: null}}) <<< ((opt = {}) <<< do
      template: template
      root: @root
      init-render: false
      text: name: ({ctx}) -> return if ctx.tab => "#{ctx.tab.name or ''}" else ''
      handler:
        tab:
          list: ({ctx}) ~>
            tabs = @_tablist.filter ->
              !(it.tab.parent.tab.id or ctx.tab.id) or
              (it.tab.parent and ctx.tab and it.tab.parent.tab.id == ctx.tab.id)
            tabs.sort (a,b) -> b.tab.order - a.tab.order
            tabs
          key: -> it.key
          view: opt
        ctrl:
          list: ({ctx}) ~>
            ret = @_ctrllist.filter ->
              if !ctx.tab => return false
              it.meta.tab == ctx.tab.id and !it.meta.hidden
            return ret
          key: -> it.key
          init: ({node, data}) ~> node.appendChild data.root
          handler: ({node, data}) ~>
            if !data.root.parentNode => node.appendChild data.root
            node.style.flex = "1 1 #{16 * (data.meta.weight or 1)}%"
            data.itf.render!
    )


konfig.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  render: (clear = false) ->
    if !@view => return
    if !@_view or clear == true =>
      if typeof(@view) == \string => @_view = @_view or konfig.views[@view].apply @
      else if typeof(@view) == \function =>
        payload =
          root: @root
          ctrls: @_ctrllist
          tabs: @_tablist
          #tree: @_ctrlobj # TBD
        # TODO we should not use apply since with parameters give us more flexibility
        @_view = @view.apply payload, [payload]
      else
        @_view = @view
        @_view.ctx {root: @root, ctrls: @_ctrllist, tabs: @_tablist}
    @_view.render!

  meta: (o = {}) ->
    # we pollute meta (e.g., with auto generated id) so we have to clone input in order to
    #  - prevent affect caller
    #  - prevent id overwritten if caller use the same obj for different subtree.
    o = JSON.parse JSON.stringify o
    {meta, tab, config} = o
    @ <<< {_meta: {}, _tab: {}}
    if !(meta?) or (typeof(meta.type) == \string) =>
      @_meta = o
      @build true
    else
      if meta? => @_meta = meta
      if tab? => @_tab = tab
      @build true, config

  default: ->
    traverse = (meta, val = {}, ctrl = {}, pid) ~>
      ctrls = if meta.child => meta.child else meta
      for id,v of ctrls =>
        if v.type => val[id] = ctrl[id].itf.default!
        else traverse(v, val{}[id], ctrl{}[id], id)
    traverse @_meta, ret = {}, @_ctrlobj, null
    ret

  reset: ->
    nv = @default!
    @set nv
    @_update!

  limited: (opt = {}) ->
    lc = any: false
    ret = {}
    traverse = (meta, val = {}, ctrl = {}) ~>
      ctrls = if meta.child => meta.child else meta
      for id,v of ctrls =>
        if v.type =>
          val[id] = ctrl[id].itf.limited? and ctrl[id].itf.limited!
          lc.any = lc.any or val[id]
        else traverse(v, val{}[id], ctrl{}[id])
    traverse @_meta, ret, @_ctrlobj
    return if opt.detail => ret else lc.any

  get: -> JSON.parse JSON.stringify @_val
  _objwait: (p) ->
    @_objps.push p
    if @_objps.length < 100 => return
    ps = @_objps.splice 0
    @_objps.push Promise.all(ps)

  obj: ->
    @ensure-built!
      .then ~> Promise.all @_objps
      .finally ~> @_objps.splice 0
      .then ~> @_obj

  set: (nv, o = {}) ->
    # we should not overwrite `_val`,
    # since widget event handler update the original `_val` directly.
    nv = JSON.parse JSON.stringify nv
    @render!
    traverse = (meta, val = {}, obj = {}, nval = {}, ctrl = {}, pid) ~>
      if typeof(ctrls = if meta.child => meta.child else meta) != \object => return
      for id,v of ctrls =>
        if v.type =>
          if val[id] != nval[id] and !(o.append and !(nval[id]?)) =>
            val[id] = nval[id]
            ctrl[id].itf.set val[id]
            ((id)~>@_objwait(Promise.resolve(ctrl[id].itf.object val[id]).then -> obj[id] = it))(id)
        else if typeof(v) == \object => traverse(v, val{}[id], obj{}[id], nval{}[id], ctrl{}[id], id)
        else console.warn "@plotdb/konfig: set malformat config under #id", ctrls
    # ensure widgets are ready so we can call their `set` in `ctrl[id].itf.set` above.
    <~ @ensure-built!then _
    traverse @_meta, @_val, @_obj, nv, @_ctrlobj, null

  _update: (n, v) -> @fire \change, JSON.parse(JSON.stringify(@_val)), n, v
  _init: ->
    @mgr.init!
      .then ~> if @use-bundle => (konfig.bundle or []) else []
      .then (data) ~> @mgr.set data.map (d) ~> new block.class(d <<< {manager: @mgr})
      .then ~> @build!
      .then ~> return @_val

  _prepare-tab: (tab) ->
    if @_tabobj[tab.id] =>
      ctab = @_tabobj[tab.id].tab
      # collision only happened when a tab is referred but not yet created.
      # in this case, a tab is created first with depth 0, and later from autotab.
      # the tab with nonzero depth is from autotab and should overwrite the depth 0 one,
      # since the depth 0 one carries less information (only the tab id)
      if ctab.depth < tab.depth => ctab <<< {tab}
      return ctab
    root = document.createElement('div')
    @_tablist.push d = {
      root, tab
      ctrls: [], tabs: []
      key: "tabkey-#{@_tablist.length}-#{Math.random!toString(36).substring(2)}"
    }
    @_tabobj[tab.id] = d

  interface: (meta) ->
    if meta.block => {name, version, path} = meta.block{name,version, path}
    else if @typemap and (ret = @typemap(meta.type)) => {ns, name, version, path} = ret
    else [ns, name, version, path] = ['', meta.type, konfig.version, '']
    id = block.id({ns,name,version,path})
    if @{}_lib[id] => return Promise.resolve that
    @mgr.get({ns, name, version, path})
      .then -> it.create {data: meta}
      .then (b) ~> b.attach!then -> b.interface!
      .then (itf = {}) ~> @_lib[id] = itf

  _prepare-ctrl: (meta, val, obj, ctrl) ->
    id = meta.id
    if ctrl[id] => return Promise.resolve!
    if meta.block => {name, version, path} = meta.block{name,version, path}
    else if @typemap and (ret = @typemap(meta.type)) => {ns, name, version, path} = ret
    else [ns, name, version, path] = ['', meta.type, konfig.version, '']
    @mgr.get({ns, name, version, path})
      .then -> it.create {data: meta}
      .then (b) ~>
        root = document.createElement(\div)
        if !(meta.tab?) => meta.tab = 'default'
        tabo = if !@_tabobj[meta.tab] =>
          @_prepare-tab {id: meta.tab, name: meta.tab, depth: 0, parent: {tab: {}}}
        else @_tabobj[meta.tab]

        @_ctrllist.push(ctrl[id] = {
          block: b, meta, root
          key: "ctrlkey-#{@_ctrllist.length}-#{Math.random!toString(36).substring(2)}"
        })

        tabo.ctrls.push ctrl[id]
        b.attach {root, defer: true}
          .then -> b.interface!
          .then -> return ctrl[id].itf = it
      .then (item) ~>
        val[id] = v = item.get!
        @_objwait(Promise.resolve(item.object v).then -> obj[id] = it)
        item.on \action, (d) ~> @fire \action, {src: item, data: d}
        item.on \change, ~>
          val[id] = it
          @_objwait(Promise.resolve(item.object it).then -> obj[id] = it)
          @update id, it
      .then -> ctrl[id]

  build: (clear = false, cfg) ->
    @ensure-built.running = true
    <~ Promise.resolve!then _
    @_build-tab clear
    @_build-ctrl clear
      .then ~> @_ctrllist.map (c) -> c.block.attach!
      .then ~> @render clear
      .then ~> if cfg? => @set cfg
      .then ~> @update!
      .then ~>
        @ensure-built.running = false
        @ensure-built.resolve!
        return

  _build-ctrl: (clear = false) ->
    promises = []
    traverse = (meta, val = {}, obj = {},  ctrl = {}, pid, ptabo) ~>
      if !(meta and typeof(meta) == \object) => return
      ctrls = if meta.child => meta.child else meta
      tab = if meta.child => meta.tab else null

      if !tab and @autotab and pid =>
        tab = "tabid-#{@_tablist.length}-#{Math.random!toString(36).substring(2)}"
        tabo = @_prepare-tab {
          id: tab, name: pid
          depth: if ptabo => ptabo.tab.depth + 1 else 0
          parent: if ptabo => ptabo else {tab: {}}
        }
        if ptabo => ptabo.tabs.push tabo

      if !ctrls => return
      for id,v of ctrls =>
        if v.type =>
          v <<< {id} <<< (if tab and !v.tab => {tab} else {})
          promises.push @_prepare-ctrl(v, val, obj, ctrl)
          continue
        traverse(v, val{}[id], obj{}[id], ctrl{}[id], id, tabo)

    if clear and @_ctrllist =>
      @_ctrllist.map ({block, root}) ->
        if block.destroy => block.destroy!
        if root.parentNode => root.parentNode.removeChild root
    if clear or !@_val => @ <<< {_val: {}, _obj: {}}
    if clear or !@_ctrlobj => @_ctrlobj = {}
    if clear or !@_ctrllist => @_ctrllist = []
    traverse @_meta, @_val, @_obj, @_ctrlobj, null
    Promise.all promises

  _build-tab: (clear = false) ->
    # TODO: clarify what is this. remove it if this is not used.
    if @render-mode == \ctrl => return
    if clear and @_tablist => @_tablist.map ({root}) -> if root.parentNode => root.parentNode.removeChild root
    if clear or !@_tablist => @_tablist = []
    if clear or !@_tab => @_tab = {}
    if clear => @_tabobj = {}
    traverse = (tab, depth = 0, parent = {tab: {}}) ~>
      if !(tab and (Array.isArray(tab) or typeof(tab) == \object)) => return
      list = if Array.isArray(tab) => tab
      else [{id,v} for id,v of tab].map ({id,v},i) -> v <<< {id}
      for order from 0 til list.length =>
        item = list[order]
        item <<< {depth, parent} <<< (if !(v.name) => {name: item.id} else {})
        item <<< if !(v.order?) => {order} else {}
        tabo = @_prepare-tab item
        traverse item.child, ((item.depth or 0) + 1), tabo
    traverse @_tab

konfig.merge = (des = {}, ...objs) ->
  _ = (des = {}, src = {}) ->
    [dc,sc] = [(if des.child => des.child else des), (if src.child => src.child else src)]
    for k,v of sc =>
      if v.type or (dc[k] and dc[k].type) =>
        if !dc[k] => dc[k] = src[k]
        else if dc[k] => dc[k] <<< src[k]
      else if typeof(sc[k]) == \object
        dc[k] = _(dc[k], sc[k])
    return des
  for i from 0 til objs.length => des = _ des, JSON.parse(JSON.stringify(objs[i]))
  return des

konfig.append = (...cs) ->
  ret = {}
  _ = (a, b) ->
    for k,v of b =>
      if typeof(v) == \object =>
        if !typeof(a[k]) == \object => a[k] = {}
        _(a[k], v)
      a[k] = v
  for i from cs.length - 2 to 0 by -1
    [c1, c2] = [JSON.parse(JSON.stringify(cs[i])), cs[i + 1]]
    _ c1, c2
  return c1

konfig.version = 'main'
if module? => module.exports = konfig
else if window? => window.konfig = konfig
