module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
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
    update-value = (o={}) ->
      v = "#{obj.ldrs.get!}#{obj.unit}"
      if !o.init and v != obj.v => pubsub.fire \event, \change, v
      obj.v = v
    set-unit = (o = {}) ~>
      u = {} <<< o.unit
      obj.unit = u.name
      if u.from? =>
        console.warn """
        [@plotdb/konfig] ctrl should use `default` for default value.
        please update your config to comply with it."""
      if u.default? => u.from = u.default
      obj.ldrs.set-config Object.fromEntries(
        <[min max step from to exp limitMax range label]>.map(~> [it, u[it]]).filter(->it.1?)
      ) <<< {unit: u.name or ''}
      update-value o{init}
      view.render!
    set-meta = (o = {}) ~>
      @_meta = m = JSON.parse(JSON.stringify(o.meta or {}))
      set-unit unit: m.units.0, init: o.init
    pubsub.fire \init, do
      # use string as return value. with this approach:
      #  - user can use the result string directly without concat value and unit
      #  - simpler against null value
      #  - user have to parse string if they need value, which will need api from this widget.
      get: -> "#{obj.ldrs.get!}#{obj.unit}" #{value: obj.ldrs.get!, unit: obj.unit}
      set: (v) ->
        ret = /^(\d+(?:\.(?:\d+))?)(\D*)/.exec("#v")
        if !ret => ret = /^(\d+(?:\.(?:\d+))?)(\D*)/.exec("#{@default!}")
        if !ret => ret = [0,0,@_meta.units.0]
        obj.ldrs.set +ret.1
        obj.unit = ret.2 or obj.unit or @_meta.units.0
        view.render!

      /*
      # alternative approach: use object as return value. with this approach:
      #  - user have to construct the result string manually,
      #  - and have to do extra check against null object.
      #  - string construction may still need api from this widget, since unit may be prefix
      get: -> {value: obj.ldrs.get!, unit: obj.unit}
      set: (v) ~>
        if typeof(obj) =>
          obj.ldrs.set v.value
          obj.unit = v.unit
        else
          obj.ldrs.set v
          obj.unit = (@_meta.default or {}).unit or @_meta.units.0.name
      */

      # TODO value should be normalized by ldslider, but this means ldslider has to provide a normalize api
      default: ~> @_meta.default
      meta: ~> set-meta meta: it
      render: -> obj.ldrs.update!

    view = new ldview do
      root: root
      init-render: false
      action: click: switch: -> obj.ldrs.edit!
      init: ldrs: ({node}) ~>
        obj.root = node
        obj.ldrs = new ldslider {root: node}
        obj.ldrs.on \change, -> update-value! #pubsub.fire \event, \change, "#{it}#{obj.unit}"
      text: picked: -> obj.unit
      handler: unit:
        list: ~> @_meta.units
        key: -> it.name
        action: click: ({data}) -> set-unit unit: data
        text: ({data}) -> data.name

    view.init!then -> set-meta {meta: data, init: true}
