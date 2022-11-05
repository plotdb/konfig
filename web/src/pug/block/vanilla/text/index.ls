module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    {ldview} = context
    pubsub.fire \init, do
      get: -> view.get('input').value or ''
      set: -> view.get('input').value = it or ''
    view = new ldview do
      root: root
      init: input: ({node}) -> node.value = data.default or ''
      action:
        input: input: ({node}) -> pubsub.fire \event, \change, node.value
        change: input: ({node}) -> pubsub.fire \event, \change, node.value
