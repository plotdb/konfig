module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    @_meta = data
    {ldview} = context
    pubsub.fire \init, do
      get: -> view.get('select').value
      set: -> view.get('select').value = it
      default: ~> @_meta.default
      meta: ~> @_meta = it
    view = new ldview do
      root: root
      action: change: select: ({node}) -> pubsub.fire \event, \change, node.value
      handler:
        option:
          list: ~> @_meta.values
          key: -> it
          init: ({node, data}) ~>
            if @_meta.default == data => node.setAttribute \selected, \selected
          handler: ({node,data}) ->
            node.setAttribute \value, data
            node.textContent = data
