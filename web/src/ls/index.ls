ctrl = (opt={}) ->
  @opt = {} <<< opt
  @ <<< opt{name, type}
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
    _ = (n) ~>
      for k,v of n =>
        if !v => continue
        if v.type == \group => return _(v)
        @ctrls[k] = new ctrl(v)
    _ @def

  render: ->
    ps = for k,v of @ctrls =>
      n = v.type
      bmgr.get {name: "ctrl-#n", version: "0.0.1"}
        .then -> it.create!
        .then ~> it.attach {root: @root}
    Promise.all ps
