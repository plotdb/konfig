module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    {ldview} = context
    meta = (d) ~>
      @_meta = JSON.parse(JSON.stringify(d))
      @_values = @_meta.values or []
    meta data
    pubsub.fire \init, do
      get: -> view.get('input').value or ''
      set: -> view.get('input').value = it or ''
      default: ~> @_meta.default or ''
      meta: ~> meta it
    view = new ldview do
      root: root
      init: input: ({node}) -> node.value = data.default or ''
      handler:
        preset:
          list: ~> @_values or []
          key: -> it.value or it.name or it
          handler: ({node, data}) -> node.textContent = data.name or data.value or data
          action: click: ({node, data}) ->
            view.get('input').value = v = data.value or data
            pubsub.fire \event, \change, v
      action:
        input: input: ({node}) -> pubsub.fire \event, \change, node.value
        change: input: ({node}) -> pubsub.fire \event, \change, node.value
