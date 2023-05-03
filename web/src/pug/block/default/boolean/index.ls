module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: [ {name: "ldview", version: "main", path: "index.min.js"} ]
  init: ({root, context, pubsub, data}) ->
    {ldview} = context
    obj = default: false, state: undefined
    set-meta = (m={}) ~>
      @_meta = JSON.parse(JSON.stringify(m))
      obj <<< default: @_meta.default, state: if obj.state? => obj.state else @_meta.default or false
    set-meta data
    pubsub.fire \init, do
      get: -> obj.state
      set: ->
        obj.state = !!it
        view.render \switch
      default: -> obj.default
      meta: (m) -> set-meta m
    view = new ldview do
      root: root
      action: click:
        switch: ->
          obj.state = !obj.state
          view.render \switch
          pubsub.fire \event, \change, obj.state
      handler:
        switch: ({node}) -> node.classList.toggle \on, obj.state
