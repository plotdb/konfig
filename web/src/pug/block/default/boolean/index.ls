module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [ {name: "ldview", version: "main", path: "index.min.js"} ]
  init: ({root, context, pubsub, data}) ->
    {ldview} = context
    obj = {default: data.default, state: data.default or false}
    pubsub.fire \init, do
      get: -> obj.state
      set: ->
        obj.state = !!it
        view.render \switch
      default: -> obj.default
      meta: -> obj.default = it.default
    view = new ldview do
      root: root
      action: click:
        switch: ->
          obj.state = !obj.state
          view.render \switch
          pubsub.fire \event, \change, obj.state
      handler:
        switch: ({node}) -> node.classList.toggle \on, obj.state
