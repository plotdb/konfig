config = (opt={}) ->
  @root = if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
  @evt-handler = {}
  @cfg = opt.config or {}
  @value = {}
  @mgr = new block.manager registry: ({name, version}) -> "/block/#name/#version/index.html"
  @init = proxise.once ~> @_init!
  @update = debounce 150, ~> @_update!
  @

config.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  _init: ->
    @mgr.init!
      .then ~>
        @view = new ldview do
          root: @root
          handler:
            config:
              list: ~> [v for k,v of @cfg]
              key: -> it.name
              init: ({node, data}) ~>
                @_prepare {name: data.type, root: node, data: data}

  _update: -> @fire \change, @value
  _prepare: ({name,root,data}) ->
    @mgr.get({name, version: "0.0.1"})
      .then -> it.create {data}
      .then (bi) ->
        bi.attach {root} .then -> bi.interface!
      .then (item) ~>
        @value[data.name] = v = item.get!
        @update!
        item.on \change, ~>
          @value[data.name] = it
          @update!
