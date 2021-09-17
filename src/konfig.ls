konfig = (opt={}) ->
  @root = if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
  @opt = opt
  @evt-handler = {}
  @use-bundle = if (opt.use-bundle?) => opt.use-bundle else true
  @view = opt.view
  @_ctrlobj = {}
  @_ctrllist = []
  @_tabobj = {}
  @_tablist = []
  @_meta = opt.meta or {}
  @_tab = opt.tab or {}
  @_val = {}
  @typemap = opt.typemap or null
  @mgr = @mgr-chain = new block.manager registry: ({name, version, path}) ->
    throw new Error("@plotdb/konfig: #name@#version/#path is not supported")
  if opt.manager =>
    @mgr = opt.manager
    @mgr.chain @mgr-chain
  @init = proxise.once ~> @_init!
  @update = debounce 150, ~> @_update!
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
                  data.itf.render!
  recurse: ->
    template = ld$.find(@root, '[ld=template]', 0)
    template.parentNode.removeChild template
    template.removeAttribute \ld-scope
    new ldview (opt = {}) <<< do
      ctx: {tab: id: null}
      template: template
      root: @root
      init-render: false
      text: name: ({ctx}) -> return if ctx.tab => "#{ctx.tab.name or ''}" else ''
      handler:
        tab:
          list: ({ctx}) ~>
            tabs = @_tablist.filter ->
              !(it.tab.parent.id or ctx.tab.id) or
              (it.tab.parent and ctx.tab and it.tab.parent.id == ctx.tab.id)
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
            node.style.flex = "1 1 #{16 * (data.meta.weight or 1)}%"
            data.itf.render!



konfig.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  render: ->
    if !@view => return
    if !@_view =>
      if typeof(@view) == \string => @_view = konfig.views[@view].apply @
      else @_view = @view
    @_view.render!

  meta: ({meta, tab}) ->
    if meta? => @_meta = meta
    if tab? => @_tab = tab
    @build true
  get: -> JSON.parse JSON.stringify @_val
  set: ->
    @_val = JSON.parse JSON.stringify it
    @render!
  _update: -> @fire \change, @_val
  _init: ->
    @mgr.init!
      .then ~> if @use-bundle => (konfig.bundle or []) else []
      .then (data) ~> @mgr.set data.map (d) ~> new block.class(d <<< {manager: @mgr})
      .then ~> @build!

  _prepare-tab: (tab) ->
    if @_tabobj[tab.id] => return @_tabobj[tab.id] <<< {tab}
    root = document.createElement('div')
    @_tablist.push d = {root, tab, key: Math.random!toString(36).substring(2)}
    @_tabobj[tab.id] = d

  _prepare-ctrl: (meta, val, ctrl) ->
    id = meta.id
    if ctrl[id] => return Promise.resolve!
    if meta.block => {name, version, path} = meta.block{name,version, path}
    else if @typemap and (ret = @typemap(meta.type)) => {name, version, path} = ret
    else [name, version, path] = [meta.type, "master", '']
    @mgr.get({name,version,path})
      .then -> it.create {data: meta}
      .then (b) ~>
        root = document.createElement(\div)
        if !(meta.tab?) => meta.tab = 'default'
        if !@_tabobj[meta.tab] => @_prepare-tab {id: meta.tab}
        @_ctrllist.push(ctrl[id] = {block: b, meta, root, key: Math.random!toString(36).substring(2)})
        b.attach {root}
          .then -> b.interface!
          .then -> return ctrl[id].itf = it
      .then (item) ~>
        val[id] = v = item.get!
        @update!
        item.on \change, ~>
          val[id] = it
          @update!
      .then -> ctrl[id]

  build: (clear = false) ->
    @_build-tab clear
    @_build-ctrl clear
      .then ~> @render!

  _build-ctrl: (clear = false) ->
    promises = []
    traverse = (meta, val = {}, ctrl = {}) ~>
      if !(meta and typeof(meta) == \object) => return
      ctrls = if meta.child => meta.child else meta
      tab = if meta.child => meta.tab else null
      if !ctrls => return
      for id,v of ctrls =>
        if v.type =>
          v <<< {id} <<< (if tab and !v.tab => {tab} else {})
          promises.push @_prepare-ctrl(v, val, ctrl)
          continue
        traverse(v, val{}[id], ctrl{}[id])

    if clear and @_ctrllist =>
      @_ctrllist.map ({block, root}) ->
        if block.destroy => block.destroy!
        if root.parentNode => root.parentNode.removeChild root
    if clear or !@_val => @_val = {}
    if clear or !@_ctrlobj => @_ctrlobj = {}
    if clear or !@_ctrllist => @_ctrllist = []
    traverse @_meta, @_val, @_ctrlobj
    Promise.all promises

  _build-tab: (clear = false) ->
    if @render-mode == \ctrl => return
    if clear and @_tablist => @_tablist.map ({root}) -> if root.parentNode => root.parentNode.removeChild root
    if clear or !@_tablist => @_tablist = []
    if clear or !@_tab => @_tab = {}
    if clear => @_tabobj = {}
    traverse = (tab, depth = 0, parent = {}) ~>
      if !(tab and (Array.isArray(tab) or typeof(tab) == \object)) => return
      list = if Array.isArray(tab) => tab
      else [{id,v} for id,v of tab].map ({id,v},i) -> v <<< {id}
      for order from 0 til list.length =>
        item = list[order]
        item <<< {depth, parent} <<< (if !(v.name) => {name: item.id}a else {})
        item <<< if !(v.order?) => {order} else {}
        @_prepare-tab item
        traverse item.child, ((item.depth or 0) + 1), item
    traverse @_tab

if module? => module.exports = konfig
else if window? => window.konfig = konfig
