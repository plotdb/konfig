bmgr = new block.manager!
ctrl = (opt={}) ->
  @opt = {} <<< opt
  @evt-handler = {}
  @

ctrl.prototype = Object.create(Object.prototype) <<< do
  set: ->
  get: ->
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v

config-editor = (opt={}) ->
  @opt = {} <<< opt
  @def = opt.def
  @evt-handler = {}
  @init = proxise.once ~> @_init!
  @

config-editor.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  _init: -> Promise.resolve!

  get: ->
  set: ->
  parse: ->
    _ = (n) ~>
      for k,v of n =>
        if !v => continue
        if v.type == \group => return _(v)
        @ctrls[k] = new ctrl(v)
    _ @def

