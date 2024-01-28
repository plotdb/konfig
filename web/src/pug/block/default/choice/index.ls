module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    @_meta = {}
    set-meta = (m) ~> @_meta = JSON.parse(JSON.stringify(m))
    set-meta data
    {ldview} = context
    check-limited = ~>
      limited = is-limited!
      root.classList.toggle \limited, limited
    is-limited = ~>
      if @_meta.disable-limit => return false
      if !@_meta.limit? or @_meta.limit == false => return false
      !(view.get('select').value in @_meta.limit)
    pubsub.fire \init, do
      get: -> view.get('select').value
      set: (v,o={}) ->
        notify = view.get('select').value != v and !o.passive
        view.get('select').value = v
        if notify => pubsub.fire \event, \change, v
      default: ~> @_meta.default
      meta: ~> set-meta it
      limited: ~> is-limited!
    view = new ldview do
      root: root
      action: change: select: ({node}) ~>
        check-limited!
        pubsub.fire \event, \change, node.value
      handler:
        select: ({node}) ~> node.setAttribute \aria-label, (@_meta.name or 'generic')
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
    view.init!then -> check-limited!
