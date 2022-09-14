module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    {ldview} = context
    @_meta = data
    pubsub.fire \init, do
      get: -> view.get('input').value or ''
      set: -> view.get('input').value = it or ''
      default: ~> @_meta.default or ''
      meta: ~> @_meta = it
    view = new ldview do
      root: root
      init: input: ({node}) -> node.value = data.default or ''
      action:
        input: input: ({node}) -> pubsub.fire \event, \change, node.value
        change: input: ({node}) -> pubsub.fire \event, \change, node.value
