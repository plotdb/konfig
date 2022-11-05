module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    {ldview} = context
    @_meta = data
    pubsub.fire \init, do
      get: -> view.get('input').value or ''
      set: -> view.get('input').value = it or ''
      default: -> []
      meta: ~> @_meta = it
    view = new ldview do
      root: root
      init: input: ({node}) ~> if @_meta.multiple => node.setAttribute \multiple, true
      action:
        change: input: ({node}) -> pubsub.fire \event, \change, node.files
