module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'main', path: 'base'
    dependencies: [
      {name: "ldslider", version: "main", path: "index.min.css"}
      {name: "ldslider", version: "main", path: "index.min.js"}
    ]
  init: ({root, context, data, pubsub}) ->
    {ldview,ldslider} = context
    obj = {}
    @_meta = {}
    set-meta = (m) ~>
      if m.from? =>
        console.warn """
        [@plotdb/konfig] ctrl should use `default` for default value.
        please update your config to comply with it."""
      if m.default? =>
        if typeof(m.default) == \object => m <<< m.default
        else if typeof(m.default) == \number => m.from = m.default
      @_meta = JSON.parse(JSON.stringify(m))
    pubsub.fire \init, do
      get: -> obj.ldrs.get!
      set: -> obj.ldrs.set it
      # TODO this should be normalized by ldslider, but this means ldslider has to provide a normalize api
      default: ~> @_meta.default
      meta: ~>
        set-meta(it)
        obj.ldrs.set-config Object.fromEntries(
          <[min max step from to exp limitMax range label]>.map(~> [it, @_meta[it]]).filter(->it.1?)
        )
      render: -> obj.ldrs.update!
    set-meta data

    view = new ldview do
      root: root
      action: click:
        switch: -> obj.ldrs.edit!
      init: ldrs: ({node}) ~>
        obj.root = node
        obj.ldrs = new ldslider(
          {root: node} <<< Object.fromEntries(
            <[min max step from to exp limitMax range label]>.map(~> [it, @_meta[it]]).filter(->it.1?)
          )
        )
        obj.ldrs.on \change, -> pubsub.fire \event, \change, it
