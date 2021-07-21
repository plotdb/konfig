konfig = (opt={}) ->
  @root = if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
  @opt = opt
  @evt-handler = {}
  @use-bundle = if (opt.use-bundle?) => opt.use-bundle else true
  @_ctrlobj = {}
  @_ctrllist = []
  @_tabobj = {}
  @_tablist = []
  @_meta = opt.meta or {}
  @_tab = opt.tab or {}
  @_val = {}
  @typemap = opt.typemap or null
  @mgr = @mgr-fallback = new block.manager registry: ({name, version, path}) ->
    throw new Error("@plotdb/konfig: #name@#version is not supported")
  if opt.manager =>
    @mgr = opt.manager
    @mgr.set-fallback @mgr-fallback
  @init = proxise.once ~> @_init!
  @update = debounce 150, ~> @_update!
  @

konfig.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  render: -> @view.render!
  meta: ->
    if !(it?) => return @_meta
    @_meta = it
    @render!
  tab: ->
    if !(it?) => return @_tab
    @_tab = it
    @render!
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
    else if @typemap and (ret = @typemap(meta.id)) => {name, version, path} = ret
    else [name, version, path] = [meta.id, "master", '']
    @mgr.get({name,version,path})
      .then -> it.create {data: meta}
      .then (itf) ~>
        root = document.createElement(\div)
        if !(meta.tab?) => meta.tab = 'default'
        if !@_tabobj[meta.tab] => @_prepare-tab {id: meta.tab}
        @_ctrllist.push(ctrl[id] = {itf, meta, root, key: Math.random!toString(36).substring(2)})
        itf.attach {root} .then -> itf.interface!
      .then (item) ~>
        val[id] = v = item.get!
        @update!
        item.on \change, ~>
          val[id] = it
          @update!
      .then -> ctrl[id]

  _view: ->
    @view = new ldview do
      root: @root
      handler:
        config:
          list: ~> @_ctrllist
          key: -> it.key
          init: ({node, data}) ~> node.appendChild data.root

  _view-alt: ->
    @_tablist.sort (a,b) -> b.tab.order - a.tab.order
    @view = new ldview do
      root: @root
      handler:
        tab:
          list: ~> @_tablist
          key: -> it.key
          view:
            text: name: ({ctx}) -> return ctx.tab.id
            handler:
              config: 
                list: ({ctx}) ~> @_ctrllist.filter -> it.meta.tab == ctx.tab.id
                key: -> it.key
                init: ({node, data}) ~> node.appendChild data.root

  build: (clear = false) ->
    @_build-tab clear
    @_build-ctrl clear
      .then ~> @_view-alt!

  _build-ctrl: (clear = false) ->
    promises = []
    traverse = (meta, val = {}, ctrl = {}) ~>
      if !meta => return
      ctrls = if meta.child => meta.child else meta
      if !ctrls => return
      for id,v of ctrls =>
        v <<< {id}
        if v.type =>
          promises.push @_prepare-ctrl(v, val, ctrl)
          continue
        traverse(v, val{}[id], ctrl{}[id])

    if clear and @_ctrllist =>
      @_ctrllist.map ({itf, root}) ->
        if itf.destroy => itf.destroy!
        if root.parentNode => root.parentNode.removeChild root
    if clear or !@_val => @_val = {}
    if clear or !@_ctrlobj => @_ctrlobj = {}
    if clear or !@_ctrllist => @_ctrllist = []
    traverse @_meta, @_val, @_ctrlobj
    Promise.all promises

  _build-tab: (clear = false) ->
    if @render-mode == \ctrl => return
    if clear and @_tablist => @_tablist.map ({root}) -> root.parentNode.removeChild root
    if clear or !@_tablist => @_tablist = []
    if clear or !@_tab => @_tab = {}

    traverse = (tab) ~>
      if !tab => return
      list = if Array.isArray(tab) => tab
      else [{id,v} for id,v of tab].map ({id,v},i) ->
        if !(v.order?) => v.order = i
        v <<< {id}
      for item in list =>
        @_prepare-tab item
        traverse item.child
    traverse @_tab

if module? => module.exports = konfig
else if window? => window.konfig = konfig
