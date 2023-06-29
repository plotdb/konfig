module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    @_meta = {}
    set-meta = (m) ~> @_meta = JSON.parse(JSON.stringify(m))
    set-meta data
    {ldview} = context
    pubsub.fire \init, do
      get: -> view.get('select').value
      set: -> view.get('select').value = it
      default: ~> @_meta.default
      meta: ~> set-meta it
      limited: ~>
        if !@_meta.limit? => return false
        !(view.get('select').value in @_meta.limit)
    view = new ldview do
      root: root
      action: change: select: ({node}) ~>
        if @_meta.limit? =>
          limited = !(node.value in @_meta.limit)
          root.classList.toggle \limited, limited
        pubsub.fire \event, \change, node.value
      handler:
        option:
          list: ~> @_meta.values
          key: -> it
          init: ({node, data}) ~>
            val = if typeof(data) == \object => data.value else data
            if @_meta.default == val => node.setAttribute \selected, \selected
          handler: ({node,data}) ->
            {value,name} = if typeof(data) == \object => data else {value: data,name: data}
            node.setAttribute \value, value
            node.textContent = name
