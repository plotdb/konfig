module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [
      {name: "ldslider", version: "main", path: "index.min.css"}
      {name: "ldslider", version: "main", path: "index.min.js"}
    ]
    i18n:
      en: unit: "Unit"
      "zh-TW": unit: "單位"
  init: ({root, context, data, pubsub}) ->
    {ldview,ldslider} = context
    obj = {}
    @_meta = {}
    set-unit = (u) ~>
      obj.unit = u.name
      if u.from? =>
        console.warn """
        [@plotdb/konfig] ctrl should use `default` for default value.
        please update your config to comply with it."""
      if u.default? =>
        if typeof(u.default) == \object => u <<< u.default
        else if typeof(u.default) == \number => u.from = u.default
      obj.ldrs.set-config Object.fromEntries(
        <[min max step from to exp limitMax range label]>.map(~> [it, u[it]]).filter(->it.1?)
      ) <<< {unit: u.name or ''}
      view.render!
    set-meta = (m) ~>
      @_meta = JSON.parse(JSON.stringify(m))
      set-unit m.units.0
    pubsub.fire \init, do
      get: -> {value: obj.ldrs.get!, unit: obj.unit}
      set: (v) ~>
        if typeof(obj) =>
          obj.ldrs.set v.value
          obj.unit = v.unit
        else
          obj.ldrs.set v
          obj.unit = (@_meta.default or {}).unit or @_meta.units.0.name
      # TODO value should be normalized by ldslider, but this means ldslider has to provide a normalize api
      default: ~> @_meta.default
      meta: ~> set-meta it
      render: -> obj.ldrs.update!

    view = new ldview do
      root: root
      init-render: false
      action: click: switch: -> obj.ldrs.edit!
      init: ldrs: ({node}) ~>
        obj.root = node
        obj.ldrs = new ldslider {root: node}
        obj.ldrs.on \change, -> pubsub.fire \event, \change, it
      text: picked: -> obj.unit
      handler: unit:
        list: ~> @_meta.units
        key: -> it.name
        action: click: ({data}) -> set-unit data
        text: ({data}) -> data.name

    view.init!then -> set-meta data
