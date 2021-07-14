<-(->it!) _

block-factory =
  pkg:
    extend: name: '@plotdb/config.widget.default', version: 'master', path: 'base'
    dependencies: []
  init: ({root, context, pubsub}) ->
    {ldview} = context
    obj = {state: false}
    pubsub.fire \init, do
      get: -> obj.state
      set: -> obj.state = !!it
    view = new ldview do
      root: root
      action: click:
        switch: ->
          obj.state = !obj.state
          view.render \switch
          pubsub.fire \event, \change, obj.state
      handler:
        switch: ({node}) -> node.classList.toggle \on, obj.state

return block-factory
