module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: [
      {name: "ldslider", version: "main", path: "index.min.css"}
      {name: "ldslider", version: "main", path: "index.min.js"}
    ]
  init: ({root, context, data, pubsub}) ->
    {ldview,ldslider} = context
    obj = {}
    @_meta = {}
    ldrs-cfg = ~>
      if !obj.ldrs => return
      o = Object.fromEntries(
        <[min max step from to exp limitMin limitMax range label]>.map(~> [it, @_meta[it]]).filter(->it.1?)
      )
      if !has-limit! =>
        delete o.limitMin
        delete o.limitMax
      obj.ldrs.set-config o
    set-meta = (m) ~>
      if m.from? =>
        console.warn """
        [@plotdb/konfig] ctrl should use `default` for default value.
        please update your config to comply with it."""
      if m.default? =>
        if typeof(m.default) == \object => m <<< m.default
        else if typeof(m.default) == \number => m.from = m.default
      @_meta = JSON.parse(JSON.stringify(m))
      ldrs-cfg!
    check-limited = ~> root.classList.toggle \limited, is-limited!
    has-limit = ~> return !@_meta.disable-limit and !!(@_meta.limit-max? or @_meta.limit-min?)
    is-limited = ~>
      if !has-limit! => return false
      v = obj.ldrs.get!
      return (
        (@_meta.limit-max? and v > @_meta.limit-max) or
        (@_meta.limit-min? and v <= @_meta.limit-min)
      )
    pubsub.fire \init, do
      get: -> obj.ldrs.get!
      set: (v, o={}) ->
        fire = obj.ldrs.get! != v and !o.passive
        obj.ldrs.set(v)
        if fire => pubsub.fire \event, \change, v
        check-limited!
      # TODO this should be normalized by ldslider, but this means ldslider has to provide a normalize api
      default: ~> @_meta.default
      meta: ~> set-meta(it)
      limited: -> is-limited!
      render: -> obj.ldrs.update!
    set-meta data

    view = new ldview do
      root: root
      action: click: switch: -> obj.ldrs.edit!
      init: ldrs: ({node}) ~>
        obj.root = node
        obj.ldrs = new ldslider({root: node})
        ldrs-cfg!
        obj.ldrs.on \change, (v) ~>
          check-limited!
          pubsub.fire \event, \change, v
        check-limited!
