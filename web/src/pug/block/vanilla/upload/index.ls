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
      init: input: ({node}) -> if data.multiple => node.setAttribute \multiple, true
      action:
        change: input: ({node}) -> pubsub.fire \event, \change, node.files
