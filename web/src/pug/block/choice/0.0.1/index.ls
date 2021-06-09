<-(->it!) _

block-factory =
  pkg:
    name: 'choice', version: '0.0.1'
    extend: name: 'base', version: '0.0.1'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    cfg = data
    {ldview} = context
    pubsub.fire \init, do
      get: -> view.get('select').value
      set: -> view.get('select').value = it
    view = new ldview do
      root: root
      action: change: select: ({node}) -> pubsub.fire \event, \change, node.value
      handler:
        option:
          list: -> cfg.values
          key: -> it
          init: ({node, data}) ->
            if cfg.default == data => node.setAttribute \selected, \selected
          handler: ({node,data}) ->
            node.setAttribute \value, data
            node.textContent = data

return block-factory
