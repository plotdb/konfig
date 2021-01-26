ctrl = (opt={}) ->
  @opt = {} <<< opt
  @ <<< opt{name, type, group}
  @evt-handler = {}
  @

ctrl.prototype = Object.create(Object.prototype) <<< do
  set: ->
  get: ->
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v


config-editor = (opt={}) ->
  @opt = {} <<< opt
  @root = if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
  @def = opt.def
  @evt-handler = {}
  @ctrls = {}
  @groups = {}
  @init = proxise.once ~> @_init!
  @init!
  @

config-editor.bmgr = bmgr = new block.manager!
config-editor.types = <[choice boolean palette color number text paragraph upload font]>
config-editor.init = proxise ->
  bmgr.init!
    .then ->
      config-editor.types.map (n) ->
        bmgr.set { name: "ctrl-#n", version: '0.0.1', block: new block.class { root: "\#ctrl-#{n}"} }


config-editor.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  _init: -> config-editor.init!

  get: ->
  set: ->

  parse: ->
    @groups[''] = {child: {}, root: @root, key: ''}
    mkg = (k, v) ~>
      root = document.createElement \div
      root.classList.add \group
      root.setAttribute \data-name, k
      @groups[k] = {child: {}, root: root, key: k} <<< (v or {})

    _ = (n,g) ~>
      for k,v of n =>
        if g.key => v.group = g.key
        if !v => continue
        if !@groups[v.group or ''] => mkg (v.group or ''), {}
        if v.type == \group =>
          mkg k,v
          _(v, @groups[k])
          continue
        @ctrls[k] = new ctrl(v)
    _ @def, @groups['']
    for k,v of @groups => if k =>
      @groups[v.group or ''].root.appendChild v.root


  render: ->
    ps = [{k,v} for k,v of @ctrls].map ({k,v}) ~>
      n = v.type
      bmgr.get {name: "ctrl-#n", version: "0.0.1"}
        .then -> it.create!
        .then ~>
          node = @groups[v.group or ''].root
          it.attach {root: node}
    Promise.all ps
